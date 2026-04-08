# 💤 LazyVim for Ubuntu Linux

This is a personal Neovim configuration based on the [LazyVim](https://github.com/LazyVim/LazyVim) starter template, tuned for Ubuntu desktop and laptop workflows.

LazyVim is built with:

+ [LazyVim Default Options](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua)
+ [LazyVim Default Keymaps](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua)

## Prerequisites

Install the core tools required by this setup:

```bash
sudo apt update
sudo apt install -y neovim git curl fzf ripgrep fd-find build-essential unzip xclip wl-clipboard
```

Notes:

- This config expects Neovim 0.11+.
- On Ubuntu, `fd-find` installs the `fdfind` binary. Some tools expect `fd`, so add a symlink if needed:

```bash
mkdir -p ~/.local/bin
ln -sf "$(command -v fdfind)" ~/.local/bin/fd
```

## Nerd Font

A Nerd Font is recommended so icons render correctly in UI components (statusline, picker, completion, etc.).

Quick option:

```bash
sudo apt install -y fonts-jetbrains-mono
```

For full Nerd Font icon coverage, install a Nerd Font release from [nerdfonts.com](https://www.nerdfonts.com/font-downloads) and select it in your terminal.

## Installation

If you already use Neovim, back up existing config and state first:

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

Clone this repository:

```bash
git clone git@github.com:jkkow/lazyvim.git ~/.config/nvim
```

Or with HTTPS:

```bash
git clone https://github.com/jkkow/lazyvim.git ~/.config/nvim
```

Start Neovim:

```bash
nvim
```

On first launch, `lazy.nvim` bootstraps itself and installs plugins.

## Verification

Run this inside Neovim after initial plugin install:

```vim
:checkhealth
```

If anything is missing, install the reported dependency and restart Neovim.

## Linux Directory Layout (XDG)

Neovim follows XDG directories by default on Ubuntu/Linux:

+ Config: `~/.config/nvim/`
+ Data: `~/.local/share/nvim/`
+ State: `~/.local/state/nvim/`
+ Cache: `~/.cache/nvim/`

If your setup becomes unstable, removing data/state/cache directories is usually safe; Neovim recreates them on next start.
