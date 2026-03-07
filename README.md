# Dev Terminal Setup

Configuração moderna de terminal para desenvolvedores com:

- ZSH + Oh My Zsh + Powerlevel10k
- zsh-autosuggestions
- zsh-syntax-highlighting
- zsh-you-should-use
- Nerd Font (instalação automática)
- Tema de cores personalizado (iTerm2, GNOME Terminal, Windows Terminal)
- Configuração automática de Cursor / VSCode

Funciona em **Linux**, **WSL (Windows)** e **macOS**.

---

# Preview

Terminal limpo para desenvolvimento com:

- integração com git
- autosuggestions
- syntax highlighting
- prompt rápido
- paleta de cores estilo hacker

---

# Início rápido

```bash
git clone https://github.com/YOURUSER/dev-terminal-setup
cd dev-terminal-setup
chmod +x install.sh
./install.sh
```

O instalador cuida de tudo automaticamente:
- Instala a Nerd Font
- Instala ZSH, Oh My Zsh, Powerlevel10k e plugins
- Aplica o tema de cores
- Configura o Cursor e o VSCode (se instalados)

Ao final, execute `p10k configure` para personalizar o prompt.

---

# Comandos disponíveis

| Comando | O que faz |
|---------|-----------|
| `./install.sh` | Instalação completa |
| `./install.sh --update` | Atualiza plugins e tema |
| `./install.sh --uninstall` | Remove tudo que foi instalado |
| `./install.sh --help` | Exibe ajuda |

---

# Nerd Font

O Powerlevel10k exige Nerd Fonts. O instalador baixa e instala a **MesloLGS NF** automaticamente.

Caso queira instalar manualmente: https://www.nerdfonts.com/font-downloads

---

# Escolha seu sistema

Siga o passo a passo do seu sistema abaixo.

---

# Passo a passo: Linux (Ubuntu, Debian, PopOS)

## 1. Instalar a fonte

Baixe a MesloLGS Nerd Font, extraia e coloque os arquivos `.ttf` em:

```
~/.local/share/fonts
```

Atualize o cache de fontes:

```bash
fc-cache -fv
```

## 2. Configurar a fonte no terminal

Abra **Terminal → Preferências → Perfil → Texto**.

- Ative **Fonte personalizada**.
- Selecione **MesloLGS Nerd Font**.

## 3. Instalar o setup

Clone o repositório e entre na pasta:

```bash
git clone https://github.com/YOURUSER/dev-terminal-setup
cd dev-terminal-setup
```

Execute o instalador:

```bash
chmod +x install.sh
./install.sh
```

## 4. Reiniciar o terminal

Feche e abra o terminal de novo (ou abra uma nova aba).

## 5. Configurar o Powerlevel10k

Execute:

```bash
p10k configure
```

Escolha o estilo que preferir.

## 6. Tema de cores

No Linux, o instalador já aplica o tema **Dev Terminal** no perfil padrão do GNOME Terminal. Se não aplicou, abra **Terminal → Preferências → Perfil** e confira se o perfil em uso está com as cores desejadas.

---

# Passo a passo: WSL (Windows)

## 1. Instalar a fonte no Windows

No **Windows** (não dentro do WSL):

1. Baixe a **MesloLGS Nerd Font** em https://www.nerdfonts.com/font-downloads.
2. Extraia o ZIP e instale as fontes: clique com o botão direito em cada `.ttf` → **Instalar** (ou “Instalar para todos os usuários”).

Assim o Windows Terminal consegue usar a fonte.

## 2. Configurar a fonte no Windows Terminal

1. Abra o **Windows Terminal**.
2. **Configurações** (Ctrl+,) → **Perfil padrão** → **Aparência**.
3. Em **Fonte**, selecione **MesloLGS Nerd Font**.
4. Salve.

## 3. Instalar o setup dentro do WSL

No WSL (Ubuntu/Debian), clone e rode o instalador:

```bash
git clone https://github.com/YOURUSER/dev-terminal-setup
cd dev-terminal-setup
chmod +x install.sh
./install.sh
```

## 4. Reiniciar o Windows Terminal

Feche e abra o Windows Terminal (ou abra um novo painel WSL).

## 5. Configurar o Powerlevel10k

No WSL:

```bash
p10k configure
```

Escolha o estilo que preferir.

## 6. Tema de cores (opcional)

O script não altera o Windows Terminal. Para um visual parecido:

1. **Configurações** do Windows Terminal → **Temas** ou **Cores** do perfil.
2. Escolha um tema escuro (ex.: “Campbell”, “One Half Dark”) ou personalize as cores manualmente.
3. Sugestão: fundo escuro (ex. `#001c23`) e texto verde claro (`#b4ffb4`).

---

# Passo a passo: macOS

## 1. Instalar o Homebrew (se ainda não tiver)

Abra o **Terminal** e rode:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Siga as instruções. No final, pode ser necessário adicionar o `brew` ao PATH (o próprio instalador mostra o comando).

## 2. Instalar a fonte no Mac

1. Baixe a **MesloLGS Nerd Font** em https://www.nerdfonts.com/font-downloads.
2. Extraia o ZIP e abra os arquivos `.ttf` para instalar (vão para o app Fontes do sistema).

Ou, via Homebrew:

```bash
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
```

## 3. Configurar a fonte no terminal

**Se usar Terminal.app (nativo):**

- **Terminal** → **Preferências** (Cmd+,) → **Perfis** → **Texto**.
- Em **Fonte**, selecione **MesloLGS Nerd Font**.

**Se usar iTerm2:**

- **iTerm2** → **Settings** (Cmd+,) → **Profiles** → **Text**.
- Em **Font**, selecione **MesloLGS Nerd Font**.

## 4. Instalar o setup

Clone e execute:

```bash
git clone https://github.com/YOURUSER/dev-terminal-setup
cd dev-terminal-setup
chmod +x install.sh
./install.sh
```

Se o script pedir senha, é para o `chsh` (trocar o shell padrão para zsh).

## 5. Reiniciar o terminal

Feche e abra o Terminal (ou iTerm2) de novo.

## 6. Configurar o Powerlevel10k

```bash
p10k configure
```

Escolha o estilo que preferir.

## 7. Tema de cores no Mac

**iTerm2:**

1. **iTerm2** → **Settings** → **Profiles** → **Colors**.
2. Em **Color Presets** → **Import**.
3. Selecione o arquivo do repositório: `configs/Dev Terminal.itermcolors`.
4. Depois escolha **Dev Terminal** em **Color Presets**.

**Terminal.app:**

- **Terminal** → **Preferências** → **Perfis** → escolha um perfil → **Ventana** (ou **Text**) e ajuste **Cor do texto** e **Cor do fundo** manualmente, por exemplo:
  - Fundo: RGB (0, 28, 35).
  - Texto: RGB (180, 255, 180).

---

# Plugins incluídos

### zsh-autosuggestions

Sugere comandos a partir do histórico. Ao digitar `git chec`, aparece a sugestão `git checkout`. Pressione `→` para aceitar.

### zsh-syntax-highlighting

Comandos válidos aparecem em verde; comandos inválidos em vermelho, em tempo real.

### zsh-you-should-use

Te lembra quando você digitou um comando que tem alias definido. Exemplo: se você digitar `git status` e tiver o alias `gs`, o plugin avisa para você usar o alias.

---

# Resumo por sistema

| Sistema | Instalador | Tema de cores |
|--------|------------|----------------|
| **Linux** | `apt` (zsh, git, curl) | Aplicado automaticamente no GNOME Terminal. |
| **WSL** | `apt` (igual ao Linux) | Ajuste manual no Windows Terminal. |
| **macOS** | Homebrew (zsh, git, curl) | iTerm2: importar `configs/Dev Terminal.itermcolors`. Terminal.app: ajuste manual. |

---

# Estrutura do projeto

```
.
├── install.sh                          # Orquestrador principal (install/update/uninstall)
├── configs/
│   ├── zshrc.template                  # Configuração do ZSH (histórico, aliases, exports)
│   ├── Dev Terminal.itermcolors        # Tema para iTerm2
│   ├── terminal_colors.dconf           # Tema para GNOME Terminal (Linux)
│   └── windows-terminal-profile.json  # Tema + perfil para Windows Terminal
└── scripts/
    ├── install_fonts.sh                # Instala MesloLGS NF automaticamente
    ├── install_zsh.sh                  # Instala ZSH, Oh My Zsh, Powerlevel10k
    ├── install_plugins.sh              # Instala plugins do ZSH
    ├── apply_terminal_theme.sh         # Aplica o tema de cores no terminal
    └── configure_editors.sh            # Configura Cursor/VSCode automaticamente
```
