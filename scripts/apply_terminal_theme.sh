#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DCONF_FILE="$PROJECT_DIR/configs/terminal_colors.dconf"

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
echo "Applying terminal color theme ($OS)..."

case "$OS" in
  linux)
    if ! command -v dconf &>/dev/null; then
      echo "⚠ dconf não encontrado. Pule o tema em Terminal → Preferências manualmente."
      exit 0
    fi
    DEFAULT_PROFILE=$(dconf read /org/gnome/terminal/legacy/profiles:/default 2>/dev/null | tr -d "'" || true)
    if [ -z "$DEFAULT_PROFILE" ]; then
      echo "⚠ Nenhum perfil padrão do GNOME Terminal. Crie um em Preferências e rode de novo."
      exit 0
    fi
    if [ -f "$DCONF_FILE" ]; then
      echo "  Carregando tema no perfil: $DEFAULT_PROFILE"
      dconf load "/org/gnome/terminal/legacy/profiles:/:${DEFAULT_PROFILE}/" < "$DCONF_FILE"
      echo "Tema aplicado."
    else
      echo "⚠ Arquivo não encontrado: $DCONF_FILE"
    fi
    ;;
  wsl)
    echo "⚠ No WSL o tema é do Windows Terminal."
    echo "  Veja no README: Passo a passo WSL → Tema de cores (Windows Terminal)."
    ;;
  macos)
    if [ -f "$PROJECT_DIR/configs/Dev Terminal.itermcolors" ]; then
      echo "  Para iTerm2: Preferências → Profiles → Colors → Color Presets → Import"
      echo "  Selecione: $PROJECT_DIR/configs/Dev Terminal.itermcolors"
    fi
    echo "  Para Terminal.app: veja no README a seção macOS → Tema de cores."
    ;;
  *)
    echo "Sistema não suportado para tema automático."
    ;;
esac
