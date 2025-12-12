# 💤 LazyVim

Nevim setup using starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

Default configuration of the LazyVim template started

+ [Default options](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua)
+ [Default Keymaps](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua)

## Default Neovim Configuration directory

Default configuration directory location of Neovim on Windows system is

```
~\AppData\Local\nvim
```

make this folder as symbolic link targetting `~\.config\nvim\` directory and manage the configuration in there via git.

## Git Config Manamgement

Personal git repo location --> (git@github.com:jkkow/lazyvim.git)

Clone this repo to `~\.config\nvim\` with the following command.

```shell
git clone git@github.com:jkkow/lazyvim.git ~\.config\nvim
```
