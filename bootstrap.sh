#!/usr/bin/env bash

cd $(dirname "${BASH_SOURCE}")

HOMEBREW_DIR=/opt/homebrew
APPDIR="/Applications"
DOTFILES_REMOTE="https://github.com/tipplrio/dotfiles.git"
DOTFILES_LOCAL=$(pwd)
DOTFILES_HOME=$HOME
DOTFILES_IGNORE=$(<dotignore)
LOCALHOST_VAR="${DOTFILES_LOCAL}/.ansible/host_vars/localhost"

function bootstrap() {
  echo "Updating OS X. If this requires a restart, run the script again."
  sudo softwareupdate -iva

  echo "Installing Xcode Command Line Tools."
  xcode-select --install

  # Check for Homebrew and install if we don't have it.
  if [[ $(which brew) != ${HOMEBREW_DIR}* ]]; then
    echo "Installing Homebrew."
    mkdir -p ${HOMEBREW_DIR}
    curl -L https://github.com/Homebrew/homebrew/tarball/master | tar xz --strip 1 -C ${HOMEBREW_DIR}
    export PATH="${HOMEBREW_DIR}/bin:$PATH"
  fi

  echo "Updating Homebrew and managed packages."
  brew update
  brew upgrade --all

  echo "Installing Python and Ansible via Homebrew."
  brew install python ansible
  rm -rf ${DOTFILES_HOME}/.ansible
  ln -s ${DOTFILES_LOCAL}/.ansible ${DOTFILES_HOME}

  echo "Configuring the playbook variables."
  cat <<EOF > ${LOCALHOST_VAR}
---
appdir: "${APPDIR}"
dotfiles_remote: "${DOTFILES_REMOTE}"
dotfiles_local: "${DOTFILES_LOCAL}"
dotfiles_home: "${DOTFILES_HOME}"
dotfiles_ignore:
EOF
  for ignore_file in $DOTFILES_IGNORE; do
    echo "  - ${ignore_file}" >> ${LOCALHOST_VAR}
  done

  echo "Running the playbook."
  cd ${DOTFILES_HOME}/.ansible
  ansible-galaxy install -f -r requirements.yml
  ansible-playbook -K -i hosts site.yml
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
