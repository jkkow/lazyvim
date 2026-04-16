# Windows Installer Guide

This directory contains the Windows 11 installer for this Neovim setup.

Ubuntu scripts were moved to `install/legacy/ubuntu/`.

## What this installer does

- Installs required tools from `install/manifests/windows-base.txt`.
- Optionally installs extra tools from `install/manifests/windows-optional.txt`.
- Optional tools currently include Python, lazygit, and JetBrainsMono Nerd Font.
- Uses `winget` installers in `install/installers/winget/`.
- Uses fallback download installers from `install/installers/fallback/` when version checks fail.
- Runs Neovim post steps in `install/post/neovim.ps1`.
- Creates `%LOCALAPPDATA%\nvim` as a link to `~/.config/nvim`.
- Installs JetBrainsMono Nerd Font in optional mode.

## Usage

Run from the repository root in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\install\install.ps1 -BaseOnly
powershell -ExecutionPolicy Bypass -File .\install\install.ps1 -All
```

Flags:

- `-BaseOnly`: install only required tools.
- `-All`: install required and optional tools.
- `-Help`: show help.

## Runtime flow

`install/install.ps1` runs these phases:

1. `BASE INSTALLATION`
2. `OPTIONAL INSTALLATION` (unless `-BaseOnly`)
3. `POST INSTALLATION`
4. `INSTALLATION SUMMARY`

Manifest entries are executed sequentially and shown as:

```text
[INFO] [3/5] Running installers/winget/ripgrep.ps1
```

## Directory structure

```text
install/
  install.ps1
  INSTALLATION.md
  manifests/
    windows-base.txt
    windows-optional.txt
  installers/
    winget/
      lazygit.ps1
      nerd-font.ps1
    fallback/
  post/
    neovim.ps1
  lib/
    common.ps1
    version.ps1
    tool_versions.ps1
  legacy/
    ubuntu/
```

## Post-install link behavior

After package installation, `install/post/neovim.ps1`:

- checks source config at `~/.config/nvim`
- backs up existing `%LOCALAPPDATA%\nvim` if needed
- creates `%LOCALAPPDATA%\nvim` as a junction (or symbolic link fallback)
- validates `init.lua` visibility through the link
- validates Neovim startup with `nvim --headless "+qa"`

## Font behavior

- Optional install includes `install/installers/winget/nerd-font.ps1`.
- Font files are installed to `%LOCALAPPDATA%\Microsoft\Windows\Fonts`.
- Neovim GUI clients use `JetBrainsMono Nerd Font:h11` from `lua/config/options.lua`.
- Terminal font (Windows Terminal/WezTerm) must be selected in terminal settings.

## Validation

- Run installer twice to confirm idempotency.
- Confirm `%LOCALAPPDATA%\nvim` points to `~/.config/nvim`.
- Run `:checkhealth` inside Neovim.
