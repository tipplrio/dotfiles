#!/usr/bin/env bash

echo "Making the environment up-to-date."
cd ~/.ansible

# Ask for the administrator password upfront.
if [ "$(whoami)" != "root" ]; then
  sudo -v

  # Keep-alive: update existing `sudo` time stamp until the script has finished.
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

OPTIONS='-i hosts'

OPTIONS=( $OPTIONS )
OPTIONS=("${OPTIONS[@]}" "$@")

ansible-playbook site.yml "${OPTIONS[@]}"

unset OPTIONS
