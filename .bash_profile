export PATH="/opt/homebrew/bin:$PATH"
export MANPATH="/opt/homebrew/share/man:$MANPATH"
export EDITOR="atom"
export NVM_DIR=~/.nvm
export ANDROID_HOME=`brew --prefix`/opt/android-sdk

if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

if [ -f ~/.aliases ]; then
  source ~/.aliases
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

source `brew --prefix nvm`/nvm.sh
eval "$(gulp --completion=bash)"
