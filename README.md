# Dev Terminal Setup

Configuração moderna de terminal para desenvolvedores com:

- ZSH + Oh My Zsh + Powerlevel10k
- zsh-autosuggestions
- zsh-syntax-highlighting
- zsh-you-should-use
- Nerd Font (instalação automática)
- Tema de cores personalizado (iTerm2, Terminal.app, GNOME Terminal, Windows Terminal)
- Configuração automática de Cursor / VSCode

Funciona em **Linux**, **WSL (Windows)** e **macOS**.

---

# Preview

Terminal limpo para desenvolvimento com:

- integração com git (branch, status, ahead/behind)
- autosuggestions baseadas no histórico
- syntax highlighting em tempo real
- prompt rápido com Powerlevel10k (preset rainbow pré-configurado)
- paleta de cores estilo hacker

---

# Início rápido

```bash
git clone https://github.com/YOURUSER/dev-terminal-setup
cd dev-terminal-setup
chmod +x install.sh
./install.sh
```

O instalador cuida de **tudo automaticamente**, sem nenhuma ação manual:

- Instala o Homebrew (macOS), se necessário
- Instala a Nerd Font
- Instala ZSH, Oh My Zsh, Powerlevel10k e plugins
- Aplica a configuração do Powerlevel10k (preset rainbow)
- Aplica o tema de cores no terminal do sistema
- Configura o Cursor e o VSCode (se instalados)

Ao final, **basta abrir um novo terminal** — tudo já estará funcionando.

> Execute `p10k configure` a qualquer momento para personalizar o prompt.

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

# Passo a passo: Linux (Ubuntu, Debian, PopOS)

## 1. Instalar o setup

Clone o repositório e execute o instalador:

```bash
git clone https://github.com/YOURUSER/dev-terminal-setup
cd dev-terminal-setup
chmod +x install.sh
./install.sh
```

O script instala automaticamente: `zsh`, `git`, `curl`, a fonte MesloLGS NF, o Oh My Zsh, o Powerlevel10k com preset rainbow e aplica o tema **Dev Terminal** no perfil padrão do GNOME Terminal.

## 2. Abrir um novo terminal

Feche e abra o terminal (ou abra uma nova aba). O prompt já estará configurado.

> Se os ícones aparecerem como `?` ou caixas, verifique se o terminal está usando a fonte **MesloLGS Nerd Font** em **Terminal → Preferências → Perfil → Texto**.

---

# Passo a passo: WSL (Windows)

## 1. Instalar o setup dentro do WSL

No WSL (Ubuntu/Debian), clone e execute o instalador:

```bash
git clone https://github.com/YOURUSER/dev-terminal-setup
cd dev-terminal-setup
chmod +x install.sh
./install.sh
```

O script instala automaticamente: dependências, fontes, ZSH, Oh My Zsh, Powerlevel10k com preset rainbow e configura o Windows Terminal (esquema de cores **Dev Terminal** + perfil com fonte MesloLGS NF).

## 2. Abrir um novo terminal

Feche e reabra o Windows Terminal. O perfil **Dev Terminal (WSL)** já estará disponível e configurado como padrão.

> A fonte MesloLGS NF é instalada dentro do WSL, mas o Windows Terminal usa fontes do Windows. Se os ícones não aparecerem, instale a fonte no Windows manualmente:
> 1. Baixe em https://www.nerdfonts.com/font-downloads
> 2. Extraia e clique com botão direito em cada `.ttf` → **Instalar para todos os usuários**

---

# Passo a passo: macOS

## 1. Instalar o setup

Clone e execute:

```bash
git clone https://github.com/YOURUSER/dev-terminal-setup
cd dev-terminal-setup
chmod +x install.sh
./install.sh
```

O script instala automaticamente:
- **Homebrew** (se não estiver instalado)
- A fonte **MesloLGS NF** via Homebrew Cask
- ZSH, Oh My Zsh, Powerlevel10k com preset rainbow
- **iTerm2**: cria o perfil **Dev Terminal** com cores e fonte configuradas e o define como padrão
- **Terminal.app**: instala o perfil **Dev Terminal** com cores e o define como padrão (requer Xcode Command Line Tools para as cores — instale com `xcode-select --install`)

## 2. Abrir um novo terminal

Feche e abra o iTerm2 (ou Terminal.app). O perfil **Dev Terminal** já estará ativo.

> Se o script pedir senha, é para o `chsh` (trocar o shell padrão para zsh).

---

# Plugins incluídos

### zsh-autosuggestions

Sugere comandos a partir do histórico. Ao digitar `git chec`, aparece a sugestão `git checkout`. Pressione `→` para aceitar.

### zsh-syntax-highlighting

Comandos válidos aparecem em verde; comandos inválidos em vermelho, em tempo real.

### zsh-you-should-use

Te lembra quando você digitou um comando que tem alias definido. Exemplo: se você digitar `git status` e tiver o alias `gs`, o plugin avisa para usar o alias.

---

# Resumo por sistema

| Sistema | Instalador | Tema de cores |
|--------|------------|----------------|
| **Linux** | `apt` (zsh, git, curl) | Aplicado automaticamente no GNOME Terminal. |
| **WSL** | `apt` (igual ao Linux) | Aplicado automaticamente no Windows Terminal. ¹ |
| **macOS** | Homebrew (instalado automaticamente) | Aplicado automaticamente no iTerm2 e Terminal.app. ² |

¹ A fonte precisa ser instalada no Windows se os ícones não aparecerem (ver seção WSL).  
² As cores do Terminal.app requerem Xcode CLT (`xcode-select --install`).

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
    ├── install_zsh.sh                  # Instala ZSH, Oh My Zsh, Powerlevel10k e preset p10k
    ├── install_plugins.sh              # Instala plugins do ZSH
    ├── apply_terminal_theme.sh         # Aplica o tema no iTerm2, Terminal.app, GNOME e Windows Terminal
    └── configure_editors.sh            # Configura Cursor/VSCode automaticamente
```
