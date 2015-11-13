#!/usr/bin/env bash

cd $(dirname "${BASH_SOURCE}")

BREW_DIR=/opt/homebrew
APP_DIR="/Applications"
DOTFILES_REMOTE="https://github.com/tipplrio/dotfiles.git"
DOTFILES_LOCAL=$(pwd)
DOTFILES_HOME=$HOME
DOTFILES_IGNORE=$(<dotignore)
LOCALHOST_VAR="${DOTFILES_LOCAL}/.ansible/host_vars/localhost"

function bootstrap() {
  # Ask for the administrator password upfront.
  sudo -v

  # Keep-alive: update existing `sudo` time stamp until the script has finished.
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  echo "Updating OS X. If this requires a restart, run the script again."
  sudo softwareupdate -iva

  echo "Installing Xcode Command Line Tools."
  xcode-select --install

  # Check for Homebrew and install if we don't have it.
  if [[ $(which brew) != ${BREW_DIR}* ]]; then
    if [ -z $(which brew) ]; then
      echo "Uninstalling the existing Homebrew."
      sudo ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
    fi
    echo "Installing Homebrew."
    sudo mkdir -p ${BREW_DIR}
    sudo chown -R $(id -un) ${BREW_DIR}
    sudo chgrp -R $(id -gn) ${BREW_DIR}
    curl -L https://github.com/Homebrew/homebrew/tarball/master | tar xz --strip 1 -C ${BREW_DIR}
    export PATH="${BREW_DIR}/bin:$PATH"
  fi

  echo "Installing Python and Ansible via Homebrew."
  brew install python ansible
  rm -rf ${DOTFILES_HOME}/.ansible
  ln -s ${DOTFILES_LOCAL}/.ansible ${DOTFILES_HOME}

  echo "Configuring the playbook variables."
  mkdir -p $(dirname ${LOCALHOST_VAR})
  cat <<EOF > ${LOCALHOST_VAR}
---
brew_dir: "${BREW_DIR}"
bin_dir: "${BREW_DIR}/bin"
app_dir: "${APP_DIR}"
dotfiles_remote: "${DOTFILES_REMOTE}"
dotfiles_local: "${DOTFILES_LOCAL}"
dotfiles_home: "${DOTFILES_HOME}"
dotfiles_ignore:
EOF
  for ignore_file in $DOTFILES_IGNORE; do
    echo "  - ${ignore_file}" >> ${LOCALHOST_VAR}
  done

  echo "Install the required Ansible roles."
  cd ${DOTFILES_HOME}/.ansible
  ansible-galaxy install -f -r requirements.yml

  cd ${DOTFILES_LOCAL}
  echo 'Now you can run the playbook by executing the script: `./update.sh`'
}

if [ "$1" == '-f' -o "$1" == '--force' ]; then
  bootstrap
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    bootstrap
  fi;
fi;

unset bootstrap
