#!/usr/bin/env bash

echo "===================  ABOUT  ================="
echo "                                             "
echo "    This script ensure minimal Archlinux     "
echo "          dependencies for neovim            "
echo "                                             "
echo "============================================="

set -euo pipefail

USERNAME="anon"
ZSH_BIN="/usr/bin/zsh"

if [[ $EUID -eq 0 ]]; then
  pacman -Syu --noconfirm
  pacman -S --needed --noconfirm \
    base-devel git zsh neovim ripgrep fd unzip wget curl openssh \
    nodejs npm python python-pip python-pynvim jdk-openjdk \
    lazygit tree-sitter-cli

  grep -qxF "$ZSH_BIN" /etc/shells || echo "$ZSH_BIN" >> /etc/shells
  if ! id -u "$USERNAME" &>/dev/null; then
    useradd -m -G wheel -s "$ZSH_BIN" "$USERNAME"
  else
    chsh -s "$ZSH_BIN" "$USERNAME"
  fi

  echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel
  chmod 0440 /etc/sudoers.d/wheel
  printf '[user]\ndefault=%s\n' "$USERNAME" > /etc/wsl.conf
  cp "$0" "/home/$USERNAME/setup.sh"
  chown "$USERNAME":"$USERNAME" "/home/$USERNAME/setup.sh"
  chmod 0755 "/home/$USERNAME/setup.sh"
  exec su - "$USERNAME" -c "exec bash /home/$USERNAME/setup.sh"
fi

touch "$HOME/.zshrc" "$HOME/.zshenv"
mkdir -p "$HOME/.config"
[[ -d "$HOME/.config/nvim" ]] || git clone https://github.com/etieppo/nvim "$HOME/.config/nvim"

if ! command -v yay >/dev/null 2>&1; then
  tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  ( cd "$tmp/yay" && makepkg -si --noconfirm )
  rm -rf "$tmp"
fi

yay -S --needed --noconfirm jdtls win32yank-bin

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ ! -d "$HOME/.nvm" ]]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
if [[ ! -d "$HOME/.cargo" ]]; then
  curl -fsSL https://sh.rustup.rs | sh -s -- -y
fi
if [[ ! -d "$HOME/.bun" ]]; then
  curl -fsSL https://bun.sh/install | bash
fi

echo "End script; exec zsh"
