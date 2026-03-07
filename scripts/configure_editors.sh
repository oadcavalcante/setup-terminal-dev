#!/usr/bin/env bash

set -euo pipefail

FONT_FAMILY="MesloLGS NF"

# Paths para settings.json do Cursor e VSCode
CURSOR_SETTINGS="$HOME/Library/Application Support/Cursor/User/settings.json"
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"

# Linux
if [[ "$(uname -s)" != "Darwin" ]]; then
  CURSOR_SETTINGS="$HOME/.config/Cursor/User/settings.json"
  VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
fi

patch_settings() {
  local settings_file="$1"
  local editor_name="$2"

  if [[ ! -f "$settings_file" ]]; then
    return
  fi

  # Verifica se já está configurado
  if grep -q "terminal.integrated.fontFamily" "$settings_file" 2>/dev/null; then
    echo "  ✓ $editor_name já tem terminal.integrated.fontFamily configurado."
    return
  fi

  echo "  Configurando fonte no $editor_name..."

  # Usa Python para manipular o JSON com segurança (evita sed em JSON)
  python3 - "$settings_file" "$FONT_FAMILY" <<'PYEOF'
import sys
import json
import re

settings_path = sys.argv[1]
font_family = sys.argv[2]

with open(settings_path, "r") as f:
    content = f.read()

# Remove comentários de linha (// ...) para parsear o JSON
clean = re.sub(r'//[^\n]*', '', content)

try:
    data = json.loads(clean)
except json.JSONDecodeError as e:
    print(f"  ⚠ Não foi possível parsear {settings_path}: {e}", file=sys.stderr)
    sys.exit(0)

data["terminal.integrated.fontFamily"] = font_family

# Reescreve o arquivo sem os comentários para manter JSON válido
with open(settings_path, "w") as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
    f.write("\n")

print(f"  ✓ terminal.integrated.fontFamily definida como '{font_family}'")
PYEOF
}

echo "Configuring editor terminal fonts..."

patch_settings "$CURSOR_SETTINGS" "Cursor"
patch_settings "$VSCODE_SETTINGS" "VSCode"

echo "Editor configuration done."
