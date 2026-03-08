#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODE="install"

usage() {
  cat <<EOF
Usage: ./install.sh [OPTIONS]

Options:
  (none)       Instalação completa (padrão)
  --update     Atualiza plugins e tema sem reinstalar tudo
  --uninstall  Remove o que foi instalado pelo setup
  --help       Exibe esta mensagem

EOF
}

# Parse args
for arg in "$@"; do
  case "$arg" in
    --update)    MODE="update" ;;
    --uninstall) MODE="uninstall" ;;
    --help|-h)   usage; exit 0 ;;
    *)
      echo "Opção desconhecida: $arg"
      usage
      exit 1
      ;;
  esac
done

# ==============================
# INSTALL
# ==============================
do_install() {
  echo "🚀 Starting Dev Terminal Setup..."
  echo ""

  bash "$SCRIPT_DIR/scripts/install_fonts.sh"
  bash "$SCRIPT_DIR/scripts/install_zsh.sh"
  bash "$SCRIPT_DIR/scripts/install_plugins.sh"
  bash "$SCRIPT_DIR/scripts/apply_terminal_theme.sh"
  bash "$SCRIPT_DIR/scripts/configure_editors.sh"

  echo ""
  echo "✅ Installation complete."
  echo ""
  echo "Next steps:"
  echo "  1. Abra um novo terminal (ou reinicie o atual)"
  echo "     → O Powerlevel10k já vem configurado com o preset rainbow."
  echo "     → Execute 'p10k configure' a qualquer momento para personalizar."
  echo "  2. No Cursor/VSCode: reabra o terminal integrado para ver os ícones."
  echo ""
  echo "  macOS (iTerm2) → O perfil 'Dev Terminal' foi criado automaticamente."
  echo "  macOS (Terminal.app) → Perfil instalado como padrão (requer Xcode CLT para cores)."
  echo "  WSL → Windows Terminal configurado automaticamente."
}

# ==============================
# UPDATE
# ==============================
do_update() {
  echo "🔄 Updating Dev Terminal plugins..."
  echo ""

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  update_repo() {
    local dir="$1"
    local name="$2"
    if [[ -d "$dir/.git" ]]; then
      echo "  Atualizando $name..."
      git -C "$dir" pull --ff-only
    else
      echo "  ⚠ $name não encontrado em $dir — rode ./install.sh primeiro."
    fi
  }

  # Oh My Zsh
  update_repo "$HOME/.oh-my-zsh" "Oh My Zsh"

  # Powerlevel10k
  update_repo "${ZSH_CUSTOM}/themes/powerlevel10k" "Powerlevel10k"

  # Plugins
  update_repo "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"    "zsh-autosuggestions"
  update_repo "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" "zsh-syntax-highlighting"
  update_repo "${ZSH_CUSTOM}/plugins/you-should-use"          "you-should-use"

  echo ""
  echo "✅ Update complete. Reabra o terminal para aplicar."
}

# ==============================
# UNINSTALL
# ==============================
do_uninstall() {
  echo "🗑  Uninstalling Dev Terminal Setup..."
  echo ""

  # Restaura o .zshrc backup mais recente, se existir
  LATEST_BACKUP=$(ls -t "$HOME"/.zshrc.backup.* 2>/dev/null | head -1 || true)
  if [[ -n "$LATEST_BACKUP" ]]; then
    echo "  Restaurando backup: $LATEST_BACKUP"
    cp "$LATEST_BACKUP" "$HOME/.zshrc"
  else
    echo "  ⚠ Nenhum backup de .zshrc encontrado. Removendo o atual."
    rm -f "$HOME/.zshrc"
  fi

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # Remove o fallback do .bashrc se existir
  if grep -q "dev-terminal-setup: auto-start zsh" "$HOME/.bashrc" 2>/dev/null; then
    echo "  Removendo fallback zsh do ~/.bashrc..."
    # Remove o bloco entre o marcador e o 'fi' correspondente
    python3 - "$HOME/.bashrc" <<'PYEOF'
import sys
path = sys.argv[1]
with open(path) as f:
    content = f.read()
marker = "# dev-terminal-setup: auto-start zsh"
start = content.find("\n" + marker)
if start == -1:
    start = content.find(marker)
    if start > 0:
        start -= 1
if start != -1:
    end = content.find("\nfi\n", start)
    if end != -1:
        content = content[:start] + content[end + 4:]
    with open(path, "w") as f:
        f.write(content)
    print("  ✓ Fallback removido do ~/.bashrc.")
PYEOF
  fi

  echo "  Removendo plugins..."
  rm -rf "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  rm -rf "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
  rm -rf "${ZSH_CUSTOM}/plugins/you-should-use"

  echo "  Removendo Powerlevel10k..."
  rm -rf "${ZSH_CUSTOM}/themes/powerlevel10k"
  rm -f "$HOME/.p10k.zsh"

  read -r -p "  Remover Oh My Zsh também? [s/N] " confirm
  if [[ "${confirm,,}" == "s" ]]; then
    if [[ -f "$HOME/.oh-my-zsh/tools/uninstall.sh" ]]; then
      bash "$HOME/.oh-my-zsh/tools/uninstall.sh" --unattended
    else
      rm -rf "$HOME/.oh-my-zsh"
    fi
    echo "  Oh My Zsh removido."
  fi

  echo ""
  echo "✅ Uninstall complete. Reabra o terminal."
}

# ==============================
# DISPATCH
# ==============================
case "$MODE" in
  install)   do_install ;;
  update)    do_update ;;
  uninstall) do_uninstall ;;
esac
