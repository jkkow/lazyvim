# AGENTS.md - Neovim Configuration Repository

## Overview

This is a **Neovim configuration** repository using LazyVim framework. It is NOT a typical software project with build/lint/test commands. Instead, it's a collection of Lua files that configure the Neovim editor.

## Repository Structure

```
nvim/
├── init.lua                 -- Entry point, bootstraps lazy.nvim
├── lua/
│   ├── config/
│   │   ├── lazy.lua         -- Plugin manager setup (lazy.nvim)
│   │   ├── options.lua      -- Neovim options (vim.opt)
│   │   ├── keymaps.lua      -- Keyboard mappings
│   │   └── autocmds.lua     -- Auto commands
│   ├── plugins/             -- Plugin specifications
│   │   ├── opencode.lua     -- opencode.nvim plugin
│   │   └── ignore.lua       -- Ignore plugin config
│   └── after/
│       └── ftplugin/        -- Filetype-specific settings
│           └── python.lua   -- Python filetype settings
├── stylua.toml              -- Lua formatter configuration
├── lazyvim.json             -- LazyVim extras config
├── lazy-lock.json           -- Locked plugin versions
└── doc/                     -- User documentation
    └── opencode.md         -- opencode.nvim usage guide
```

## Build/Lint/Test Commands

This is **NOT a traditional software project**. There are no build, lint, or test commands.

### Editor Commands (for development)

- `:Lazy` - Open LazyVim plugin manager UI
- `:LspInfo` - Show LSP server status
- `:checkhealth` - Run Neovim health checks
- `:lua require("lazy").sync()` - Sync plugins

### Running Individual Tests

Not applicable - this is a Neovim configuration, not a testable codebase.

### Linting

The codebase uses **stylua** for Lua formatting:
- Config: `stylua.toml`
- Rules: 2-space indentation, 120 column width

To format manually (if stylua is installed):
```bash
stylua lua/
```

## Code Style Guidelines

### Language

- **Language**: Lua (Neovim configuration)
- **Version**: Lua 5.1 (Neovim's embedded LuaJIT)

### Formatting (stylua)

From `stylua.toml`:
```toml
indent_type = "Spaces"
indent_width = 2
column_width = 120
```

### Naming Conventions

- **Variables**: `snake_case` (e.g., `local lazypath`, `vim.opt`)
- **Functions**: `snake_case` (e.g., `vim.keymap.set`, `require("lazy").setup`)
- **Tables/Keys**: `snake_case` (e.g., `{ desc = "..." }`, `{ "lazy", false }`)
- **Plugin names**: kebab-case in spec (e.g., `"folke/lazy.nvim"`)

### Imports and Requires

```lua
-- Plugin spec (returns table)
return {
  "author/plugin-name",
  dependencies = { "dependency/plugin" },
  config = function()
    require("module.name").setup()
  end,
}

-- Local require for performance
local lazy = require("lazy")
local fn = vim.fn
local opt = vim.opt
```

### Keymaps

Always use `vim.keymap.set()` with explicit mode and description:

```lua
local map = vim.keymap.set

-- Format: map(mode, lhs, rhs, opts)
map("n", "<leader>fc", function() ... end, { desc = "Find configuration" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map({ "n", "t" }, "<C-t>", "<cmd>tabnew<cr>", { desc = "New tab" })
```

Valid modes: `"n"`, `"i"`, `"v"`, `"x"`, `"s"`, `"o"`, `"t"`, `"c"`, `"l"`

### Plugin Specifications

Follow LazyVim plugin spec format:

```lua
return {
  "author/plugin-name",
  -- Version constraint: "*" for latest, "^1.0.0" for semver, false for git
  version = false,
  -- Event triggers: "VeryLazy", "BufRead", etc.
  event = "VeryLazy",
  -- Dependencies
  dependencies = { "dependency/plugin" },
  -- Configuration
  opts = { key = "value" },
  config = function()
    -- Setup code
  end,
}
```

### Options (vim.opt)

```lua
local opt = vim.opt

opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
```

### Error Handling

- Use `vim.v.shell_error` for shell command checks
- Use `pcall(require, "module")` for optional dependencies
- Show errors with `vim.api.nvim_echo()` for user-facing errors

### Comments

- Use `--` for single-line comments
- Use `--[[ ]]` for block comments
- Include descriptive section headers in config files:

```lua
------------------------------------------------------------------------------
-- 1. Section Name
------------------------------------------------------------------------------
```

### File Organization

1. `init.lua` - Bootstrap lazy.nvim (keep minimal)
2. `lua/config/lazy.lua` - Plugin manager setup
3. `lua/config/options.lua` - Neovim options
4. `lua/config/keymaps.lua` - Keybindings
5. `lua/config/autocmds.lua` - Autocommands
6. `lua/plugins/*.lua` - Plugin specifications
7. `lua/after/ftplugin/*.lua` - Filetype-specific settings

### Documentation Files

User-facing documentation lives in `doc/`. These are Markdown files intended for end-users to understand how to use the Neovim setup.

- `doc/*.md` - Documentation for plugins and features
- Keep documentation practical and user-focused
- Document keymaps, configuration options, and usage examples

### Testing Changes

Since this is a Neovim config:

1. Restart Neovim to apply changes
2. Or use `:luafile %` to reload current file
3. Use `:Lazy reload <plugin>` to reload specific plugin
4. Check `:messages` for errors

### Environment-Specific Code

Follow the pattern in `options.lua` for platform-specific settings:

```lua
if vim.fn.has("wsl") == 1 then
  -- WSL-specific settings
elseif vim.fn.has("win32") == 1 then
  -- Windows-specific settings
else
  -- Linux/macOS settings
end
```

### Best Practices

1. **Lazy loading**: Use `event`, `cmd`, `keys` in plugin specs for performance
2. **Descriptive keymaps**: Always include `desc` in keymap options
3. **Local variables**: Use `local` for variables to avoid global pollution
4. **Module caching**: Use `local M = {}` pattern for modules
5. **Version pinning**: Use `version = false` for git HEAD, `version = "*"` for stable
