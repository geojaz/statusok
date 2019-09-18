#!/bin/bash

# This script can be run safely multiple times.
# It's tested on macOS High Sierra (10.13). It:
# - installs, upgrades, or skips system packages
# - creates or updates symlinks from `$OK/dotfiles` to `$HOME`
# - installs or updates programming languages such as Ruby, Node, and Go

set -ex

HOMEBREW_PREFIX="/usr/local"

if [ -d "$HOMEBREW_PREFIX" ]; then
  if ! [ -r "$HOMEBREW_PREFIX" ]; then
    sudo chown -R "$LOGNAME:admin" "$HOMEBREW_PREFIX"
  fi
else
  sudo mkdir "$HOMEBREW_PREFIX"
  sudo chflags norestricted "$HOMEBREW_PREFIX"
  sudo chown -R "$LOGNAME:admin" "$HOMEBREW_PREFIX"
fi

update_shell() {
  local shell_path;
  shell_path="$(command -v zsh)"

  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  chsh -s "$shell_path"
}

case "$SHELL" in
  */zsh)
    if [ "$(command -v zsh)" != "$HOMEBREW_PREFIX/bin/zsh" ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

if ! command -v brew >/dev/null; then
  curl -fsS \
    'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby
  export PATH="/usr/local/bin:$PATH"
fi

brew analytics off
brew update
brew bundle --file=- <<EOF
# fzf fuzzy file search; used by vim
brew "fzf"

# the git on mac is crippled
brew "git"
brew "git-lfs"
brew "hub" # github cli

brew "jq"
brew "libyaml"
brew "openssl"
brew "protobuf"

# bash linter
brew "shellcheck"
brew "the_silver_searcher"
brew "zsh"
brew "tmux"
brew "vim"
brew "watch"
cask "kitty"

EOF

brew upgrade
brew cleanup

(
  cd "$OK/dotfiles"

  ln -sf "$PWD/editor/vimrc" "$HOME/.vimrc"

  mkdir -p "$HOME/.vim/ftdetect"
  mkdir -p "$HOME/.vim/ftplugin"
  (
    cd editor/vim
    for f in {ftdetect,ftplugin}/*; do
      ln -sf "$PWD/$f" "$HOME/.vim/$f"
    done
  )

  ln -sf "$PWD/git/gitconfig" "$HOME/.gitconfig"
  ln -sf "$PWD/git/gitignore" "$HOME/.gitignore"
  ln -sf "$PWD/git/gitmessage" "$HOME/.gitmessage"

  ln -sf "$PWD/shell/curlrc" "$HOME/.curlrc"
  
  mkdir -p "$HOME/.config/kitty"
  ln -sf "$PWD/shell/kitty.conf" "$HOME/.config/kitty/kitty.conf"

  mkdir -p "$HOME/.ssh"
  ln -sf "$PWD/shell/ssh" "$HOME/.ssh/config"

  ln -sf "$PWD/shell/tmux.conf" "$HOME/.tmux.conf"
  ln -sf "$PWD/shell/zshrc" "$HOME/.zshrc"
  ln -sf "$PWD/sql/psqlrc" "$HOME/.psqlrc"

)

if [ -e "$HOME/.vim/autoload/plug.vim" ]; then
  vim -u "$HOME/.vimrc" +PlugUpgrade +qa
else
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim -u "$HOME/.vimrc" +PlugUpdate +PlugClean! +qa

# Go
gover="1.13"
if ! go version | grep -Fq "$gover"; then
  sudo rm -rf /usr/local/go
  curl "https://dl.google.com/go/go$gover.darwin-amd64.tar.gz" | \
    sudo tar xz -C /usr/local
fi
