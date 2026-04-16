# LazyVim for Windows 11

This is a personal Neovim configuration based on the [LazyVim](https://github.com/LazyVim/LazyVim) starter template, tuned for Windows 11 workflows.

LazyVim defaults used in this repo:

- [LazyVim Default Options](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua)
- [LazyVim Default Keymaps](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua)

## Prerequisites (Windows 11)

Install core tools with `winget` (PowerShell):

```powershell
winget install --id gerardog.gsudo -e --scope machine
winget install --id Neovim.Neovim -e --scope machine
winget install --id Git.Git -e
winget install --id BurntSushi.ripgrep.MSVC -e
winget install --id sharkdp.fd -e
winget install --id junegunn.fzf -e
```

Optional:

```powershell
winget install --id Python.Python.3.12 -e
winget install --id OpenJS.NodeJS.LTS -e
winget install --id JesseDuffield.lazygit -e
```

When you run `install/install.ps1 -All`, the installer also adds Python, Node.js (LTS), lazygit, and JetBrainsMono Nerd Font.
Base installation now installs `gsudo` first, then `neovim`.

Notes:

- This config expects Neovim 0.11+.
- Neovim on Windows 11 uses the native clipboard provider.

## Nerd Font

A Nerd Font is recommended so icons render correctly in statusline, pickers, completion menus, and diagnostics.

- Install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/font-downloads).
- Set that font in your terminal profile (Windows Terminal, WezTerm, etc.).

## Installation

If you already use Neovim, back up your existing directories first:

```powershell
Move-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.bak" -ErrorAction SilentlyContinue
Move-Item "$env:LOCALAPPDATA\nvim-data" "$env:LOCALAPPDATA\nvim-data.bak" -ErrorAction SilentlyContinue
```

Clone this repository into `~/.config/nvim`:

```powershell
git clone https://github.com/jkkow/lazyvim.git "$HOME\.config\nvim"
```

Run the installer from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\install\install.ps1 -All
```

`-ExecutionPolicy Bypass` in this command applies to that PowerShell process only. It does not permanently change your machine/user execution policy.

Installer scope examples:

```powershell
powershell -ExecutionPolicy Bypass -File .\install\install.ps1 -All -Scope user
powershell -ExecutionPolicy Bypass -File .\install\install.ps1 -All -MachineScope
```

Install a single tool separately (example: `fzf`):

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\install\installers\winget\fzf.ps1
```

or:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install\installers\winget\fzf.ps1
```

Notes:

- Run these commands from the repository root (or use absolute paths).
- Running an individual installer script skips the top-level checks and summary from `install/install.ps1`.
- The `fzf` script can fall back to `install/installers/fallback/fzf.ps1` if winget does not provide the required version.
- Installer default scope is `machine`; use `-Scope user` to override.
- `gsudo` and `neovim` are treated as critical installers (failure stops the run).
- `neovim` automatically falls back to `install/installers/fallback/neovim.ps1` when winget install fails.
- If `POST INSTALLATION` appears slow, it is usually the first `nvim --headless "+qa"` plugin bootstrap/clone step.
- `%LOCALAPPDATA%\nvim` is created as a junction first; if junction creation fails, the script falls back to a symbolic link.
- Nerd Font updates can skip in-use files (for example, when terminal apps are open). Close those apps and rerun to refresh all files.

Manifests:

- `install/manifests/windows-base.txt` defines required installer script paths.
- `install/manifests/windows-optional.txt` defines optional installer script paths.
- `install/install.ps1` runs each listed script sequentially in order.

Minimum required versions:

- `install/min-required-versions.txt` is the source of truth for minimum tool versions.
- The installer compares installed versions against this file and installs/upgrades only when needed.
- Tools listed there but not managed by installer scripts are shown as `not-managed` in the final summary.

The installer links `%LOCALAPPDATA%\nvim` to `~/.config/nvim` automatically (junction first, then symbolic link fallback).
For GUI Neovim clients (Neovide, nvim-qt), this repo sets `guifont` to `JetBrainsMono Nerd Font:h11`.

Start Neovim:

```powershell
nvim
```

`lazy.nvim` bootstraps and installs plugins automatically on first startup. In this setup, that first bootstrap can also happen during installer post-install validation (`nvim --headless "+qa"`).

## Verification

Run inside Neovim after initial plugin install:

```vim
:checkhealth
```

Install any missing dependencies reported by health checks, then restart Neovim.

## Windows Directory Layout

Default Neovim locations on Windows 11:

- Config: `%LOCALAPPDATA%\nvim\`
- Data: `%LOCALAPPDATA%\nvim-data\`
- State: `%LOCALAPPDATA%\nvim-data\state\`
- Cache: `%LOCALAPPDATA%\nvim-data\cache\`

If your setup becomes unstable, removing `nvim-data` is usually safe; Neovim recreates it on next launch.

## Installer Scope

`install/` is Windows-first and based on PowerShell + winget.
- Default package scope is `machine`.
- Use `-Scope user` when you explicitly need per-user installs.
Legacy Ubuntu scripts are available in `install/legacy/ubuntu/`.
