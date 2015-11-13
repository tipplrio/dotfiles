#!/usr/bin/env bash

cd $(dirname "${BASH_SOURCE}")

BREW_DIR=/opt/homebrew
APP_DIR="/Applications"
DOTFILES_REMOTE="https://github.com/tipplrio/dotfiles.git"
DOTFILES_LOCAL=$(pwd)
DOTFILES_HOME=$HOME
DOTFILES_IGNORE=$(<dotignore)
LOCALHOST_VAR="${DOTFILES_LOCAL}/.ansible/host_vars/localhost"

ARG1=$1
ARG2=$2

function bootstrap() {
  # Ask for the administrator password upfront.
  if [ "$(whoami)" != "root" ]; then
    sudo -v

    # Keep-alive: update existing `sudo` time stamp until the script has finished.
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  fi

  if [ "$ARG1" != '--no-update' -a "$ARG2" != '--no-update' ]; then
    echo "Updating OS X. If this requires a restart, run the script again."
    sudo softwareupdate -iva

    if ! xcode-select -p > /dev/null ; then
      echo "Installing Xcode Command Line Tools."
      xcode-select --install
      while ! xcode-select -p > /dev/null ; do sleep 1; done
      sudo xcodebuild -license
    fi
  fi;

  # Check for Homebrew and install if we don't have it.
  if [[ $(which brew) != ${BREW_DIR}* ]]; then
    if [ $(which brew) ]; then
      echo "Uninstalling the existing Homebrew."
      curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall > uninstall
      chmod 755 uninstall
      ./uninstall --path=$(dirname $(dirname $(which brew))) --force
      rm -f uninstall
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

if [ "$ARG1" == '-f' -o "$ARG1" == '--force' -o "$ARG2" == '-f' -o "$ARG2" == '--force' ]; then
  bootstrap
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    bootstrap
  fi;
fi;

unset ARG1 ARG2 bootstrap
