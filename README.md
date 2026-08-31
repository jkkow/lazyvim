# Cross-Platform LazyVim Configuration

Personal [LazyVim](https://github.com/LazyVim/LazyVim) configuration with a consistent plugin, keymap, LSP, and theme experience on Windows, WSL, Linux, and macOS. Platform-specific shell and clipboard behavior is isolated in `lua/config/platform.lua`.

## Requirements

### Required

- Neovim 0.11.7 or later
- Git 2.30.0 or later
- Network access to GitHub for the first `lazy.nvim` and plugin bootstrap
- This repository at Neovim's configuration path:
  - Windows: `%LOCALAPPDATA%\nvim`
  - Linux, WSL, and macOS: `~/.config/nvim`

### Recommended

- `ripgrep`, `fd`, and `fzf` for search and picker workflows
- A [Nerd Font](https://www.nerdfonts.com/font-downloads) for icons
- Windows: PowerShell 7 (`pwsh`) for shell integration
- Linux: `wl-clipboard` on Wayland, or `xclip`/`xsel` on X11

### Language and Feature Support

- Python 3.12+ and Node.js 20.11.1+ for the configured Python tools (`basedpyright` and `ruff`)
- The `opencode` CLI for OpenCode plugin commands

## Installation

Back up an existing configuration before cloning.

### Windows

```powershell
git clone https://github.com/jkkow/lazyvim.git "$env:LOCALAPPDATA\nvim"
```

Install required and recommended tools with your preferred package manager. For winget:

```powershell
winget install --id Neovim.Neovim -e
winget install --id Git.Git -e
winget install --id BurntSushi.ripgrep.MSVC -e
winget install --id sharkdp.fd -e
winget install --id junegunn.fzf -e
winget install --id Microsoft.PowerShell -e
```

### Linux and WSL

```bash
git clone https://github.com/jkkow/lazyvim.git ~/.config/nvim
```

Install Neovim, Git, `ripgrep`, `fd`, and `fzf` with your distribution's package manager. Install `wl-clipboard` for Wayland or `xclip`/`xsel` for X11 clipboard support.

### macOS

```bash
git clone https://github.com/jkkow/lazyvim.git ~/.config/nvim
```

Install Neovim, Git, `ripgrep`, `fd`, and `fzf` with your preferred package manager.

Start Neovim with `nvim`. `lazy.nvim` bootstraps and installs plugins automatically on first launch.

## Platform Behavior

- Windows uses `pwsh` when available and configures `JetBrainsMono Nerd Font:h11` for GUI clients.
- WSL uses Bash and the Windows clipboard when `clip.exe` and `powershell.exe` are available.
- Linux and macOS use Neovim's default shell and clipboard providers.

## Verification

After the first plugin installation, run `:checkhealth` inside Neovim and install any missing feature-specific dependencies it reports.

## Line Ending Policy

All repository text files use LF, including Lua, PowerShell, Bash, Markdown, JSON, and TOML. `.gitattributes` enforces this independently of each developer's Git settings; `.bat` and `.cmd` are the only CRLF exceptions. `.editorconfig` keeps supporting editors aligned with the same policy.
