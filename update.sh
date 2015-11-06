#!/usr/bin/env bash

echo "Making the environment up-to-date."
cd ~/.ansible
ansible-playbook -K -i hosts site.yml
