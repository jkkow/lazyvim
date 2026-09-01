# Cross-Platform LazyVim Configuration

Personal [LazyVim](https://github.com/LazyVim/LazyVim) configuration with a consistent plugin, keymap, LSP, and theme experience on Windows, WSL, Linux, and macOS. Platform-specific shell and clipboard behavior is isolated in `lua/config/platform.lua`.

## Requirements

### Required

- Neovim 0.11.7 or later
- Git 2.30.0 or later
- Network access to GitHub for the first `lazy.nvim` and plugin bootstrap
- Windows: WinLibs (`BrechtSanders.WinLibs.POSIX.UCRT`) before starting Neovim; it provides GCC, GNU Make, CMake, Ninja, and GDB for native plugin builds
- This repository at Neovim's configuration path:
  - Windows with XDG configured: `%USERPROFILE%\.config\nvim`
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

Configure the XDG base directories so Neovim uses `%USERPROFILE%\.config` for configuration. Log off and back on, or restart Windows, before opening Neovim.

```powershell
[System.Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', "$env:USERPROFILE\.config", 'User')
[System.Environment]::SetEnvironmentVariable('XDG_DATA_HOME', "$env:USERPROFILE\.local\share", 'User')
[System.Environment]::SetEnvironmentVariable('XDG_CACHE_HOME', "$env:USERPROFILE\.cache", 'User')
```

Clone this repository directly into the XDG configuration directory:

```powershell
git clone git@github.com:jkkow/lazyvim.git "$env:USERPROFILE\.config\nvim"
```

> [!IMPORTANT]
> Do not use `~` in the clone destination on Windows. Use `$env:USERPROFILE` so PowerShell passes the intended absolute path to Git.

Before starting Neovim, install WinLibs from the PowerShell session of each account that uses Neovim. This required portable package supplies GCC, GNU Make, CMake, Ninja, and GDB for plugins with native builds:

```powershell
winget install --id BrechtSanders.WinLibs.POSIX.UCRT --exact
```

Install Neovim and Git from an elevated PowerShell session. The Neovim (WiX MSI) and Git (Inno Setup) winget packages support machine-wide installation:

```powershell
winget install --id Neovim.Neovim -e --scope machine
winget install --id Git.Git -e --scope machine
```

Install `ripgrep`, `fd`, and `fzf` from the PowerShell session of each account that uses Neovim; these portable packages register their command shims in the installing account's user PATH.

```powershell
winget install --id BurntSushi.ripgrep.MSVC -e
winget install --id sharkdp.fd -e
winget install --id junegunn.fzf -e
```

### Linux and WSL

```bash
git clone git@github.com:jkkow/lazyvim.git ~/.config/nvim
```

Install Neovim, Git, `ripgrep`, `fd`, and `fzf` with your distribution's package manager. Install `wl-clipboard` for Wayland or `xclip`/`xsel` for X11 clipboard support.

### macOS

```bash
git clone git@github.com:jkkow/lazyvim.git ~/.config/nvim
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
