# Tipplr dotfiles

This is a repository for dotfiles used in Tipplr's development environment. There is an [Ansible](http://www.ansible.com/) playbook for setting up the development environment on **OS X**.


## Things you should know

* **You should fork this repository to suit your personal needs.**
* Your default workspace is `~/Workspace`.
* This repository will be cloned in `~/Workspace/dotfiles`.
* The bootstrapping script will install [Homebrew](http://brew.sh/) in `/opt/homebrew`.
* All the dotfiles in your home directory will be symbolic-linked to those in the local repository.

## How to bootstrap

```shell
# Create Workspace directory and clone this repository in it.
$ mkdir -p ~/Workspace
$ cd ~/Workspace
$ git clone git@github.com:tipplrio/dotfiles.git
```

## Bootstrapping

```shell
# Just execute the bootstrapping script in the local repository.
$ cd ~/Workspace/dotfiles
$ ./bootstrap.sh
```

## Make your environment up-to-date

```shell
# Just run the playbook.
$ cd ~/.ansible
$ ansible-playbook -K -i hosts site.yml
```
