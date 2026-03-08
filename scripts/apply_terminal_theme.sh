#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DCONF_FILE="$PROJECT_DIR/configs/terminal_colors.dconf"
ITERMCOLORS="$PROJECT_DIR/configs/Dev Terminal.itermcolors"
WT_PROFILE_JSON="$PROJECT_DIR/configs/windows-terminal-profile.json"

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

# ==============================================================
# LINUX — GNOME Terminal via dconf
# ==============================================================
apply_linux() {
  if ! command -v dconf &>/dev/null; then
    echo "⚠ dconf não encontrado. Instale com: sudo apt install dconf-cli"
    return
  fi
  DEFAULT_PROFILE=$(dconf read /org/gnome/terminal/legacy/profiles:/default 2>/dev/null | tr -d "'" || true)
  if [[ -z "$DEFAULT_PROFILE" ]]; then
    echo "⚠ Nenhum perfil padrão do GNOME Terminal encontrado."
    echo "  Abra o terminal, crie um perfil em Preferências e rode novamente."
    return
  fi
  if [[ -f "$DCONF_FILE" ]]; then
    echo "  Carregando tema no perfil: $DEFAULT_PROFILE"
    dconf load "/org/gnome/terminal/legacy/profiles:/:${DEFAULT_PROFILE}/" < "$DCONF_FILE"
    echo "  ✓ Tema aplicado no GNOME Terminal."
  else
    echo "⚠ Arquivo não encontrado: $DCONF_FILE"
  fi
}

# ==============================================================
# macOS — iTerm2 via Dynamic Profile + defaults write
# ==============================================================
apply_iterm2() {
  local DYNAMIC_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  local PROFILE_GUID="dev-terminal-setup-v1"
  local OUTPUT="$DYNAMIC_DIR/dev-terminal.json"

  mkdir -p "$DYNAMIC_DIR"

  python3 - "$OUTPUT" "$ITERMCOLORS" "$PROFILE_GUID" <<'PYEOF'
import sys, json
import xml.etree.ElementTree as ET

output_path   = sys.argv[1]
colors_path   = sys.argv[2]
profile_guid  = sys.argv[3]

def parse_plist_dict(elem):
    d, children = {}, list(elem)
    for i in range(0, len(children), 2):
        key, val = children[i].text, children[i + 1]
        if val.tag == 'real':
            d[key] = float(val.text)
        elif val.tag == 'integer':
            d[key] = int(val.text)
        elif val.tag == 'string':
            d[key] = val.text
    return d

tree = ET.parse(colors_path)
top  = list(tree.getroot().find('dict'))
raw_colors = {}
for i in range(0, len(top), 2):
    key, val = top[i].text, top[i + 1]
    if val.tag == 'dict':
        d = parse_plist_dict(val)
        raw_colors[key] = {
            "Red Component":   d.get("Red Component", 0),
            "Green Component": d.get("Green Component", 0),
            "Blue Component":  d.get("Blue Component", 0),
            "Alpha Component": d.get("Alpha Component", 1),
            "Color Space":     d.get("Color Space", "sRGB"),
        }

COLOR_KEYS = [
    "Background Color", "Foreground Color",
    "Cursor Color", "Cursor Text Color",
    *[f"Ansi {i} Color" for i in range(16)],
]

profile = {
    "Profiles": [{
        "Name":              "Dev Terminal",
        "Guid":              profile_guid,
        "Terminal Type":     "xterm-256color",
        "Normal Font":       "MesloLGSNF-Regular 13",
        "Non Ascii Font":    "MesloLGSNF-Regular 13",
        "Use Non-ASCII Font": False,
        "Scrollback Lines":  10000,
        "Mouse Reporting":   True,
        "Silence Bell":      True,
        "Cursor Type":       1,
        "Transparency":      0.05,
        "Blur":              False,
        **{k: raw_colors[k] for k in COLOR_KEYS if k in raw_colors},
    }]
}

with open(output_path, "w") as f:
    json.dump(profile, f, indent=2)

print(f"  ✓ Dynamic Profile criado: {output_path}")
PYEOF

  # Define o perfil como padrão
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" "$PROFILE_GUID" 2>/dev/null || true
  echo "  ✓ Perfil 'Dev Terminal' definido como padrão no iTerm2."

  # Recarrega iTerm2 se estiver rodando para aplicar imediatamente
  if pgrep -xq "iTerm2"; then
    echo "  Recarregando iTerm2..."
    osascript -e 'tell application "iTerm2" to quit' 2>/dev/null || true
    sleep 1
    open -a iTerm 2>/dev/null || true
    echo "  ✓ iTerm2 reiniciado com o novo perfil."
  fi
}

# ==============================================================
# macOS — Terminal.app via PyObjC (com fallback para osascript)
# ==============================================================
apply_terminal_app() {
  echo "  Configurando Terminal.app..."

  python3 - "$PROJECT_DIR" <<'PYEOF'
import sys, os, subprocess, plistlib, tempfile

project_dir = sys.argv[1]
pref_path   = os.path.expanduser("~/Library/Preferences/com.apple.Terminal.plist")

# Gera dados NSArchiver de NSColor via swift (disponível após Xcode CLT)
def swift_color_data(r, g, b):
    code = f"""
import Foundation; import AppKit
let c = NSColor(srgbRed: {r}, green: {g}, blue: {b}, alpha: 1)
let d = try! NSKeyedArchiver.archivedData(withRootObject: c, requiringSecureCoding: false)
print(d.base64EncodedString())
"""
    with tempfile.NamedTemporaryFile(suffix=".swift", mode="w", delete=False) as f:
        f.write(code)
        tmp = f.name
    try:
        result = subprocess.run(["swift", tmp], capture_output=True, text=True, timeout=15)
        if result.returncode == 0:
            import base64
            return base64.b64decode(result.stdout.strip())
    except Exception:
        pass
    finally:
        os.unlink(tmp)
    return None

bg_data   = swift_color_data(0,        28/255, 35/255)
fg_data   = swift_color_data(180/255,  1,      180/255)
cur_data  = swift_color_data(180/255,  1,      180/255)

if bg_data is None:
    print("  ℹ Swift não disponível — Terminal.app requer configuração manual de cores.")
    print("    Instale as Command Line Tools: xcode-select --install")
    sys.exit(0)

# Lê ou cria o plist
if os.path.exists(pref_path):
    with open(pref_path, "rb") as f:
        prefs = plistlib.load(f)
else:
    prefs = {}

window_settings = prefs.get("Window Settings", {})

profile_name = "Dev Terminal"
profile = window_settings.get(profile_name, {})

profile.update({
    "name":              profile_name,
    "type":              "Window Settings",
    "ProfileCurrentVersion": 2.07,
    "BackgroundColor":   bg_data,
    "TextColor":         fg_data,
    "CursorColor":       cur_data,
    "SelectionColor":    swift_color_data(39/255, 74/255, 82/255),
    "FontWidthSpacing":  1.0,
    "FontHeightSpacing": 1.004,
    "columnCount":       220,
    "rowCount":          50,
    "ShouldLimitScrollback": 0,
    "ScrollbackLines":   10000,
})

window_settings[profile_name] = profile
prefs["Window Settings"] = window_settings

with open(pref_path, "wb") as f:
    plistlib.dump(prefs, f)

print(f"  ✓ Perfil '{profile_name}' adicionado ao Terminal.app.")

# Define como padrão
subprocess.run(["defaults", "write", "com.apple.Terminal",
                "Default Window Settings", profile_name], check=False)
subprocess.run(["defaults", "write", "com.apple.Terminal",
                "Startup Window Settings", profile_name], check=False)
print(f"  ✓ Terminal.app configurado para usar '{profile_name}' como padrão.")
PYEOF
}

# ==============================================================
# WSL — Windows Terminal via settings.json
# ==============================================================
apply_windows_terminal() {
  echo "  Configurando Windows Terminal..."

  # Localiza o settings.json (stable ou preview)
  local WT_SETTINGS=""
  for pattern in \
    "/mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json" \
    "/mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_*/LocalState/settings.json"; do
    # shellcheck disable=SC2086
    local found
    found=$(ls $pattern 2>/dev/null | head -1 || true)
    if [[ -n "$found" ]]; then
      WT_SETTINGS="$found"
      break
    fi
  done

  if [[ -z "$WT_SETTINGS" ]]; then
    echo "  ⚠ settings.json do Windows Terminal não encontrado."
    echo "    Verifique se o Windows Terminal está instalado e rode novamente."
    return
  fi

  echo "  Encontrado: $WT_SETTINGS"

  python3 - "$WT_SETTINGS" "$WT_PROFILE_JSON" <<'PYEOF'
import sys, json, re, shutil, os
from datetime import datetime

settings_path = sys.argv[1]
profile_path  = sys.argv[2]

with open(settings_path, "r", encoding="utf-8") as f:
    raw = f.read()

# Backup antes de modificar
backup = settings_path + ".backup." + datetime.now().strftime("%Y%m%d%H%M%S")
shutil.copy(settings_path, backup)

# Remove comentários para parsear JSON
clean = re.sub(r'//[^\n]*', '', raw)
clean = re.sub(r'/\*.*?\*/', '', clean, flags=re.DOTALL)

try:
    settings = json.loads(clean)
except json.JSONDecodeError as e:
    print(f"  ⚠ Não foi possível parsear settings.json: {e}", file=sys.stderr)
    sys.exit(0)

with open(profile_path, "r", encoding="utf-8") as f:
    ref = json.load(f)

new_scheme  = ref["scheme"]
new_profile = ref["profile"]
scheme_name = new_scheme["name"]

# Insere ou atualiza o esquema de cores
schemes = settings.setdefault("schemes", [])
existing_idx = next((i for i, s in enumerate(schemes) if s.get("name") == scheme_name), None)
if existing_idx is not None:
    schemes[existing_idx] = new_scheme
else:
    schemes.append(new_scheme)

# Insere ou atualiza o perfil
profiles = settings.setdefault("profiles", {})
profile_list = profiles.setdefault("list", [])
profile_name = new_profile["name"]
existing_p = next((p for p in profile_list if p.get("name") == profile_name), None)
if existing_p is not None:
    existing_p.update(new_profile)
else:
    profile_list.insert(0, new_profile)

# Define o perfil como padrão
settings["defaultProfile"] = new_profile.get(
    "guid",
    next((p.get("guid") for p in profile_list if p.get("name") == profile_name), None)
)

with open(settings_path, "w", encoding="utf-8") as f:
    json.dump(settings, f, indent=4, ensure_ascii=False)
    f.write("\n")

print(f"  ✓ Esquema '{scheme_name}' e perfil '{profile_name}' adicionados ao Windows Terminal.")
print(f"  ✓ Perfil definido como padrão. Backup salvo em: {os.path.basename(backup)}")
PYEOF
}

# ==============================================================
# DISPATCH
# ==============================================================
case "$OS" in
  linux)
    apply_linux
    ;;
  macos)
    apply_iterm2
    apply_terminal_app
    ;;
  wsl)
    apply_windows_terminal
    ;;
  *)
    echo "Sistema não suportado para tema automático."
    ;;
esac

echo "Terminal theme setup done."
