#!/bin/bash

# This script can be safefuly run multiple times on the same machine.

# It installs, upgrades, or skips packages
# based on what is already installed on the machine.

# It then creates symlinks of the config files in this repo
# to the `~/` (`$HOME`) directory.

# Tested on macOS High Sierra (10.13).

# shellcheck disable=SC2154
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

HOMEBREW_PREFIX="/usr/local"

if [ -d "$HOMEBREW_PREFIX" ]; then
  if ! [ -r "$HOMEBREW_PREFIX" ]; then
    sudo chown -R "$LOGNAME:admin" /usr/local
  fi
else
  sudo mkdir "$HOMEBREW_PREFIX"
  sudo chflags norestricted "$HOMEBREW_PREFIX"
  sudo chown -R "$LOGNAME:admin" "$HOMEBREW_PREFIX"
fi

update_shell() {
  local shell_path;
  shell_path="$(which zsh)"

  printf "\nChanging your shell to zsh ...\n"
  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    printf "\nAdding '$shell_path' to /etc/shells\n"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  chsh -s "$shell_path"
}

case "$SHELL" in
  */zsh)
    if [ "$(which zsh)" != "$HOMEBREW_PREFIX/bin/zsh" ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

if ! command -v brew >/dev/null; then
  printf "\nInstalling Homebrew ...\n"
    curl -fsS \
      'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

    export PATH="/usr/local/bin:$PATH"
fi

printf "\nUpdating Homebrew formulae ...\n"
brew update
brew bundle --file=- <<EOF
tap "thoughtbot/formulae"
tap "homebrew/services"
tap "universal-ctags/universal-ctags"

# Unix
brew "universal-ctags", args: ["HEAD"]
brew "git"
brew "jq"
brew "openssl"
brew "reattach-to-user-namespace"
brew "shellcheck"
brew "the_silver_searcher"
brew "tmux"
brew "vim", args: ["without-ruby"]
brew "watch"
brew "watchman"
brew "zsh"
cask "ngrok"

# Heroku
brew "heroku"
brew "parity"

# GitHub
brew "hub"

# AWS
brew "awscli"
cask "aws-vault"

# Image manipulation
brew "imagemagick"

# Testing
brew "chromedriver", restart_service: :changed

# Programming languages and package managers
brew "libyaml" # should come after openssl
brew "go"

# Databases
brew "postgresql", restart_service: :changed
brew "redis", restart_service: :changed

# Data interchange
brew "protobuf"
EOF

if [ ! -d "/Applications/Expo XDE.app" ]; then
  printf "\nSet up Expo tools for React Native ...\n"
  brew cask install --force expo-xde
fi

printf "\nUpdate Heroku binary...\n"
brew unlink heroku
brew link --force heroku

printf "\nUpgrading Homebrew formulae ...\n"
brew upgrade

printf "\nCleaning up old Homebrew formulae ...\n"
brew cleanup
brew cask cleanup

echo "Symlinking dotfiles ..."
echosymlink() {
  echo "$2 -> $1"
  ln -sf "$1" "$2"
}

# CLIs for $PATH
for f in bin/*; do
  echo "$HOME/$f -> $PWD/$f"
  ln -sf "$PWD/$f" "$HOME/$f"
done

# Vim
echosymlink "$PWD/editor/vimrc" "$HOME/.vimrc"

mkdir -p "$HOME/.vim/ftdetect"
mkdir -p "$HOME/.vim/ftplugin"
cd editor/vim || exit 1
for f in {ftdetect,ftplugin}/*; do
  echosymlink "$PWD/$f" "$HOME/.vim/$f"
done
cd ../.. || exit 1

# Ruby
mkdir -p "$HOME/.bundle"
echosymlink "$PWD/ruby/bundle/config" "$HOME/.bundle/config"
echosymlink "$PWD/ruby/gemrc" "$HOME/.gemrc"
echosymlink "$PWD/ruby/rspec" "$HOME/.rspec"

# Search
cd search || exit 1
for f in *; do
  echosymlink "$PWD/$f" "$HOME/.$f"
done

# Shell
cd ../shell || exit 1
for f in *; do
  echosymlink "$PWD/$f" "$HOME/.$f"
done

# Version manager (ASDF)
cd ../versions || exit 1
for f in *; do
  echosymlink "$PWD/$f" "$HOME/.$f"
done

echo "Updating Vim plugins ..."
if [ -e "$HOME/.vim/autoload/plug.vim" ]; then
  vim -u "$HOME/.vimrc" +PlugUpgrade +qa
else
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim -u "$HOME/.vimrc" +PlugUpdate +PlugClean! +qa

printf "\nInstalling ASDF version manager ...\n"
if [ ! -d "$HOME/.asdf" ]; then
  git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.4.0
fi

. "$HOME/.asdf/asdf.sh"

asdf_plugin_add() {
  local name="$1"

  if ! asdf plugin-list | grep -Fq "$name"; then
    asdf plugin-add "$name"
  fi
}

asdf_install() {
  local language="$1"
  local version="$2"

  if ! asdf list "$language" | grep -Fq "$version"; then
    asdf install "$language" "$version"
    asdf global "$language" "$version"
  fi
}

printf "\nInstalling Ruby ...\n"
asdf_plugin_add "ruby"
asdf_install "ruby" "2.4.2"

printf "\nInstalling Node ...\n"
asdf_plugin_add "nodejs"
export NODEJS_CHECK_SIGNATURES=no
asdf_install "nodejs" "9.3.0"

printf "\nInstalling Yarn ...\n"
npm install yarn --global
asdf reshim nodejs

printf "\nInstalling Expo, Prettier, TSLint, TypeScript, Yarn ...\n"
yarn global add exp
yarn global add prettier
yarn global add tslint-config-prettier
yarn global add typescript
asdf reshim nodejs

printf "\nInstall Protobuf protocol compiler plugin for Go ...\n"
go get -u github.com/golang/protobuf/protoc-gen-go
