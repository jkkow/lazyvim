# Neovim Theme Settings

## Overview

This document explains how to visually explore Neovim themes (colorschemes), install and apply them in a LazyVim environment, and update the core plugin settings.

## Theme Search and Visual Preview

Neovim themes can be previewed visually through dedicated gallery websites, allowing you to intuitively choose one that suits your preferences.

- **Dotfyle**: A gallery of Neovim plugins and themes, with trending themes and screenshots
- **vimcolorschemes.com**: Offers various Vim and Neovim themes sorted by popularity
- **GitHub Topics**: Search for `neovim-colorscheme` tag to find the latest theme source code and previews

## Theme Installation and Application

Most community themes (excluding built-in themes) must be installed via a plugin manager like Lazy.nvim.

- Check the theme's GitHub repository to identify the exact plugin name
- Add the plugin to your Neovim configuration and specify the colorscheme activation option

## Core Updates and Application in LazyVim

LazyVim has its own core structure, so changing the theme requires overriding the LazyVim core plugin's default settings in addition to installing the theme plugin.

1. Create a `colorscheme.lua` file in `~/.config/nvim/lua/plugins/`
2. Add the theme plugin with a high `priority` value for rendering optimization
3. Override `LazyVim/LazyVim` core plugin's `opts.colorscheme` value with your desired theme name

```lua
return {
  -- 1. Add the theme plugin (example: catppuccin)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },

  -- 2. Override LazyVim core defaults
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
```

After saving the configuration file and restarting Neovim, the package manager will automatically install and apply the theme.
