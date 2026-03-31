# 💤 LazyVim for Omarchy (Arch Linux)

This is a personal Neovim configuration based on the [LazyVim](https://github.com/LazyVim/LazyVim) starter template, tailored specifically for **Omarchy** (an Arch Linux environment).

LazyVim is built with:

+ [LazyVim Default Options](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua)
+ [LazyVim Default Keymaps](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua)

## 📦 Prerequisites

To ensure all plugins and language servers work correctly on Arch Linux, you need to install the following dependencies.

### 1. Core Packages

You will need Neovim, Git, a C compiler (for `nvim-treesitter`), and essential CLI search tools:

```bash
sudo pacman -S neovim git curl fzf ripgrep fd gcc make unzip
```

> **Note**: This setup assumes **Neovim >= 0.11.2** (built with LuaJIT). If the stable `pacman` repository provides an older version, you may need to install `neovim-git` from the AUR using your preferred helper (e.g., `yay` or `paru`).

### 2. Nerd Fonts

A Nerd Font is highly recommended to correctly display icons in the UI (like NvimTree, lualine, and blink.cmp).

```bash
# Example: Install JetBrains Mono Nerd Font and general Nerd Font symbols
sudo pacman -S ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd
```

### 3. Terminal Emulator

This configuration works beautifully with modern GPU-accelerated terminal emulators commonly used in Omarchy, such as **WezTerm**, **Kitty**, or **Alacritty**.

---

## 🚀 Installation & Setup

If you have used Neovim previously, it is crucial to back up your old configuration and clear the cache/data folders before proceeding to prevent conflicts.

### 1. Backup Existing Config

```bash
# Backup current configuration
mv ~/.config/nvim ~/.config/nvim.bak

# Backup Neovim data, state, and cache
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

### 2. Clone the Repository

Clone this repository directly into your Neovim configuration directory (`~/.config/nvim`).

**Using SSH (Recommended):**

```bash
git clone git@github.com:jkkow/lazyvim.git ~/.config/nvim
```

**Using HTTPS:**

```bash
git clone https://github.com/jkkow/lazyvim.git ~/.config/nvim
```

### 3. Start Neovim

Open your terminal and launch Neovim:

```bash
nvim
```

Upon the first startup, the `lazy.nvim` package manager will automatically download itself and install all the configured plugins. Please wait for the initial installation UI to finish.

### 4. Verify the Installation

Once the plugins are successfully installed, run the following command inside Neovim to ensure your environment is fully ready and to check for any missing system dependencies:

```vim
:checkhealth
```

Pay attention to any `ERROR` or `WARNING` messages, especially under the `nvim-treesitter` or `mason` sections, and install any additionally requested packages.

---

## 📁 Linux Directory Structure (XDG)

Unlike Windows, Neovim on Omarchy (Linux) strictly follows the XDG Base Directory specification. You do not need to manually configure symbolic links.

Neovim automatically uses these directories natively:
+ **Configuration (`$XDG_CONFIG_HOME`):** `~/.config/nvim/` (Where this git repository lives)
+ **Data (`$XDG_DATA_HOME`):** `~/.local/share/nvim/` (Plugins, downloaded LSPs via Mason)
+ **State (`$XDG_STATE_HOME`):** `~/.local/state/nvim/` (Log files, undo history)
+ **Cache (`$XDG_CACHE_HOME`):** `~/.cache/nvim/`

You can safely delete `.local/share/nvim`, `.local/state/nvim`, or `.cache/nvim` at any time if you experience weird UI glitches or plugin issues; Neovim will regenerate them upon the next launch.
