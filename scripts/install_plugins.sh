#!/usr/bin/env bash

set -euo pipefail

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_or_skip() {
  local repo="$1"
  local dest="$2"
  local name="$3"

  if [[ -d "$dest" ]]; then
    echo "  ✓ $name já instalado."
  else
    echo "  Instalando $name..."
    git clone --depth=1 "$repo" "$dest"
    echo "  ✓ $name instalado."
  fi
}

echo "Installing ZSH plugins..."

clone_or_skip \
  "https://github.com/zsh-users/zsh-autosuggestions" \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions" \
  "zsh-autosuggestions"

clone_or_skip \
  "https://github.com/zsh-users/zsh-syntax-highlighting" \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" \
  "zsh-syntax-highlighting"

clone_or_skip \
  "https://github.com/MichaelAquilina/zsh-you-should-use" \
  "$ZSH_CUSTOM/plugins/you-should-use" \
  "you-should-use"

echo "Plugins installed."
