#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Detect OS: Linux, WSL, or macOS
detect_os() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "macos"
  elif uname -r 2>/dev/null | grep -qi microsoft; then
    echo "wsl"
  else
    echo "linux"
  fi
}

OS=$(detect_os)
echo "Detected OS: $OS"
echo "Installing ZSH and dependencies..."

case "$OS" in
  linux|wsl)
    sudo apt update
    sudo apt install -y zsh git curl
    ;;
  macos)
    if ! command -v brew &>/dev/null; then
      echo "Homebrew não encontrado. Instale em: https://brew.sh"
      echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    brew install zsh git curl 2>/dev/null || true
    ;;
  *)
    echo "Sistema não suportado."
    exit 1
    ;;
esac

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "Installing Powerlevel10k..."

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" 2>/dev/null || true

echo "Applying zsh config..."

if [ -f ~/.zshrc ]; then
  BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
  cp ~/.zshrc "$BACKUP"
  echo "  Backed up existing .zshrc to $BACKUP"
fi
cp "$PROJECT_DIR/configs/zshrc.template" ~/.zshrc

echo "Setting default shell..."

chsh -s "$(which zsh)" 2>/dev/null || true

echo "ZSH setup done."
