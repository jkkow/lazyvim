# Windows Installer Guide

This directory contains the Windows 11 installer for this Neovim setup.

Ubuntu scripts were moved to `install/legacy/ubuntu/`.

## What this installer does

- Installs required tools from `install/manifests/windows-base.txt`.
- Optionally installs extra tools from `install/manifests/windows-optional.txt`.
- Installs `gsudo` first in the base phase, then installs Neovim.
- Optional tools currently include Python, Node.js (LTS), lazygit, and JetBrainsMono Nerd Font.
- Reads minimum required versions from `install/min-required-versions.txt`.
- Uses `winget` installers in `install/installers/winget/`.
- Uses fallback download installers from `install/installers/fallback/` when version checks fail.
- Runs Neovim post steps in `install/post/neovim.ps1`.
- Creates `%LOCALAPPDATA%\nvim` as a link to `~/.config/nvim`.
- Uses `machine` scope by default for winget installs (with explicit user override).

## Usage

Run from the repository root in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\install\install.ps1 -BaseOnly
powershell -ExecutionPolicy Bypass -File .\install\install.ps1 -All
powershell -ExecutionPolicy Bypass -File .\install\install.ps1 -All -Scope user
powershell -ExecutionPolicy Bypass -File .\install\install.ps1 -All -MachineScope
```

`-ExecutionPolicy Bypass` here is process-scoped for that command invocation.

Flags:

- `-BaseOnly`: install only required tools.
- `-All`: install required and optional tools.
- `-Scope`: set winget scope to `machine` (default) or `user`.
- `-MachineScope`: shortcut for machine-wide installs.
- `-Help`: show help.

Scope policy:

- Default installs use `machine` scope for predictable system-wide tool paths.
- Use `-Scope user` when you intentionally want per-user package installs.
- For `machine` scope in local sessions, installer self-elevates once via UAC and then continues elevated.
- For `machine` scope over SSH, installer stops early because UAC elevation cannot be triggered remotely.

## Runtime flow

`install/install.ps1` runs these phases:

1. `ELEVATION GATE` (machine scope only; local UAC self-relaunch)
2. `BASE INSTALLATION` (`gsudo` first, then `neovim`)
3. `OPTIONAL INSTALLATION` (unless `-BaseOnly`)
4. `POST INSTALLATION`
5. `INSTALLATION SUMMARY`

For each managed tool, installers compare the currently installed version with the required version from
`install/min-required-versions.txt`:

- If not installed, install.
- If installed but lower than required, install/upgrade.
- If installed and meets required version, pass.

Failure policy:

- `gsudo` and `neovim` are critical installers. If either fails, the installer stops.
- `neovim` winget failures automatically fall back to `install/installers/fallback/neovim.ps1`.
- Other installer failures are logged and execution continues.

Manifest entries are executed sequentially and shown as:

```text
[INFO] [4/6] Running installers/winget/ripgrep.ps1
```

Each manifest line is a repository-relative path to a script under `install/` (blank lines and `#` comments are ignored).

## Running individual installer scripts

You can run a single installer script directly (example: `fzf`):

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\install\installers\winget\fzf.ps1
```

This is useful for targeted retries, but it skips top-level orchestration behaviors from `install/install.ps1` (phase banners, manifest ordering, final summary).

## Directory structure

```text
install/
  install.ps1
  INSTALLATION.md
  min-required-versions.txt
  manifests/
    windows-base.txt
    windows-optional.txt
  installers/
    winget/
      gsudo.ps1
      lazygit.ps1
      nodejs.ps1
      nerd-font.ps1
    fallback/
  post/
    neovim.ps1
  lib/
    common.ps1
    version.ps1
    version_requirements.ps1
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
- Confirm installation summary shows required vs installed versions and status for each tool.
- Run `:checkhealth` inside Neovim.
