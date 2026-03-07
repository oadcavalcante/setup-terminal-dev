#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

FONT_NAME="MesloLGS NF"
FONT_CHECK="MesloLGS NF Regular.ttf"

font_already_installed() {
  case "$OS" in
    macos)
      [[ -f "$HOME/Library/Fonts/$FONT_CHECK" ]] || \
      fc-list 2>/dev/null | grep -qi "MesloLGS NF" || \
      system_profiler SPFontsDataType 2>/dev/null | grep -qi "MesloLGS NF"
      ;;
    linux|wsl)
      fc-list 2>/dev/null | grep -qi "MesloLGS NF"
      ;;
  esac
}

install_macos() {
  if font_already_installed; then
    echo "  ✓ $FONT_NAME já está instalada."
    return
  fi

  if command -v brew &>/dev/null; then
    echo "  Instalando via Homebrew..."
    # Suporte ao novo tap unificado (homebrew-cask-fonts foi descontinuado)
    brew install --cask font-meslo-lg-nerd-font 2>/dev/null || \
      brew install --cask homebrew/cask-fonts/font-meslo-lg-nerd-font 2>/dev/null || true
    echo "  ✓ Fonte instalada via Homebrew."
  else
    install_manual_macos
  fi
}

install_manual_macos() {
  echo "  Homebrew não encontrado. Baixando manualmente..."
  FONT_DIR="$HOME/Library/Fonts"
  TMPDIR_FONTS=$(mktemp -d)

  FONTS=(
    "MesloLGS%20NF%20Regular.ttf"
    "MesloLGS%20NF%20Bold.ttf"
    "MesloLGS%20NF%20Italic.ttf"
    "MesloLGS%20NF%20Bold%20Italic.ttf"
  )

  BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"

  for font in "${FONTS[@]}"; do
    decoded="${font//%20/ }"
    echo "    Baixando: $decoded"
    curl -fsSL "$BASE_URL/$font" -o "$TMPDIR_FONTS/$decoded"
    cp "$TMPDIR_FONTS/$decoded" "$FONT_DIR/$decoded"
  done

  rm -rf "$TMPDIR_FONTS"
  echo "  ✓ Fontes instaladas em $FONT_DIR"
}

install_linux() {
  if font_already_installed; then
    echo "  ✓ $FONT_NAME já está instalada."
    return
  fi

  echo "  Baixando $FONT_NAME para Linux..."
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  TMPDIR_FONTS=$(mktemp -d)

  FONTS=(
    "MesloLGS%20NF%20Regular.ttf"
    "MesloLGS%20NF%20Bold.ttf"
    "MesloLGS%20NF%20Italic.ttf"
    "MesloLGS%20NF%20Bold%20Italic.ttf"
  )

  BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"

  for font in "${FONTS[@]}"; do
    decoded="${font//%20/ }"
    echo "    Baixando: $decoded"
    curl -fsSL "$BASE_URL/$font" -o "$TMPDIR_FONTS/$decoded"
    cp "$TMPDIR_FONTS/$decoded" "$FONT_DIR/$decoded"
  done

  rm -rf "$TMPDIR_FONTS"

  echo "  Atualizando cache de fontes..."
  fc-cache -f "$FONT_DIR" 2>/dev/null || true
  echo "  ✓ Fontes instaladas em $FONT_DIR"
}

echo "Installing Nerd Font ($FONT_NAME)..."

case "$OS" in
  macos)        install_macos ;;
  linux|wsl)    install_linux ;;
  *)
    echo "⚠ Sistema não suportado para instalação automática de fontes."
    echo "  Baixe manualmente em: https://www.nerdfonts.com/font-downloads"
    exit 0
    ;;
esac

echo "Font setup done."
