#!/usr/bin/env bash

echo "Making the environment up-to-date."
cd ~/.ansible

OPTIONS='-i hosts'
if [ -z "$*" ]; then
  OPTIONS="${OPTIONS} --ask-become-pass"
fi

OPTIONS=( $OPTIONS )
OPTIONS=("${OPTIONS[@]}" "$@")

ansible-playbook site.yml "${OPTIONS[@]}"

unset OPTIONS
