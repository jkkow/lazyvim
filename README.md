# 💤 LazyVim

Nevim setup using starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

LazyVim template started with the following default configuration

+ [Default options](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua)
+ [Default Keymaps](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua)

## Pre-requisit

+ Neovim >= 0.11.2 (needs to be built with LuaJIT)
+ Git >= 2.19.0 (for partial clones support)
  - `curl` for blink.cmp (completion engine)
+ Nerd Font(v3.0 or greater) (optional, but needed to display some icons)
+ `tree-sitter-cli` and a C compiler for nvim-treesitter. See here
+ fzf-lua (optional)
+ `fzf`: fzf (v0.25.1 or greater)
+ `ripgrep` 
+ `fd`
+ wezterm (Linux, Macos & Windows)

```shell
scoop install fzf fd ripgrep tree-sitter git 
```

`curl` will be automatically installed with git installation.

## Default Neovim Configuration directory

Default configuration directory location of Neovim on Windows system is

```
~\AppData\Local\nvim
```

make this folder as symbolic link targetting `~\.config\nvim\` directory where the neovim configuration is managed via git.
(optional) Create symbolic link for `~\AppData\Local\nvim-data\` too in the `~\.config\` directory for managing efficiency.

## Git Config Manamgement

Personal git repo location --> (git@github.com:jkkow/lazyvim.git)

Clone this repo to `~\.config\nvim\` with the following command.

```shell
git clone git@github.com:jkkow/lazyvim.git "$Home\.config\nvim"
```

> [!CAUTION]
> Never use tilda(`~`) sign for home directory representation in Powershell. This will create `~` directory.
