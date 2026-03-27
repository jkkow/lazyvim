# Agentic Coding Guidelines (AGENTS.md)

This document provides instructions for AI coding agents (like Copilot, Cursor, Opencode, or custom agents) operating within this Neovim configuration repository. It serves as the single source of truth for building, linting, formatting, testing, and stylistic guidelines.

## 1. Environment & Architecture

- **Project Type**: Neovim Configuration.
- **Base Framework**: LazyVim.
- **Language**: Lua 5.1 / LuaJIT (native to Neovim).
- **Package Manager**: `lazy.nvim`.

Agents should strive to respect the LazyVim architecture. Do not override core LazyVim defaults entirely unless instructed; instead, use the `opts` table in plugin specs to cleanly merge user settings with LazyVim defaults.

## 2. Build, Lint, and Test Commands

### 2.1 Building and Running
Since this is a Neovim configuration, there is no formal "build" step.
- **Apply Changes**: Changes to Lua files take effect immediately upon restarting Neovim (`nvim`).
- **Hot Reloading**: Some modules can be hot-reloaded via `:luafile %` or by using a Neovim plugin designed for Lua reloading, but a full restart is the safest way to verify state.

### 2.2 Formatting
The project uses `stylua` as the official formatter.
- **Check formatting**: `stylua --check .`
- **Format codebase**: `stylua .`
- **Rules**: The `stylua.toml` file enforces 2-space indentation and a 120-character column width limit. Always run `stylua` before finalizing code changes.

### 2.3 Linting
The Lua Language Server (`lua_ls`) is the primary linter used within Neovim.
- For CLI linting, `luacheck` is typically used in the Lua ecosystem.
- **Command**: `luacheck lua/` (if `luacheck` is installed on the host system).

### 2.4 Testing
Currently, this Neovim configuration does not utilize a formal test suite (like `plenary.busted`). Testing is performed manually by opening Neovim.

If `plenary.nvim` based tests are added in the future (typically placed in a `tests/` directory), use the following commands:
- **Run all tests**: `nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"`
- **Run a single test file**: `nvim --headless -c "PlenaryBustedFile tests/my_spec.lua"`

## 3. Code Style & Best Practices

### 3.1 File Structure
Adhere to the standard LazyVim directory layout:
- `lua/config/options.lua`: Core Neovim options (`vim.opt`, `vim.g`).
- `lua/config/keymaps.lua`: Global keybindings (`vim.keymap.set`).
- `lua/config/autocmds.lua`: Global autocommands (`vim.api.nvim_create_autocmd`).
- `lua/plugins/*.lua`: Plugin specifications. Return a table of Lazy.nvim specs.

### 3.2 Scope and Variables
- **Locals First**: Always declare variables and functions as `local`. Never pollute the global `_G` namespace unless absolutely necessary and specifically requested.
- **Imports**: Use `require("module_name")` to load modules. If a module is used multiple times in a file, cache it in a local variable: `local my_module = require("module_name")`.

### 3.3 Formatting Details
- **Indentation**: 2 spaces. Never use tabs.
- **Strings**: Double quotes (`"`) are preferred, but single quotes (`'`) are acceptable if the string itself contains double quotes.
- **Trailing Commas**: Always include trailing commas in multi-line tables to make git diffs cleaner.

### 3.4 Naming Conventions
- **Variables & Functions**: Use `snake_case` (e.g., `local my_variable = 1`, `local function setup_plugin()`).
- **Constants**: Use `UPPER_SNAKE_CASE` (e.g., `local MAX_RETRIES = 3`).
- **Classes/Metatables**: Use `PascalCase` if implementing OOP patterns in Lua (e.g., `local MyPlugin = {}`).

### 3.5 Type Annotations
Use EmmyLua annotations to provide type safety and enhance the Lua Language Server (`lua_ls`) experience.
- Annotate function parameters (`---@param`) and return types (`---@return`).
- Define complex table structures using `---@class` and `---@field`.

```lua
---@class PluginConfig
---@field enabled boolean Whether the plugin is enabled
---@field name string The name of the plugin

--- Initialize the plugin
---@param config PluginConfig
---@return boolean success
local function init_plugin(config)
  if not config.enabled then return false end
  print("Initializing " .. config.name)
  return true
end
```

### 3.6 Error Handling and Safety
- **Protected Calls**: When executing functions that might fail (like requiring optional dependencies or making system calls), wrap them in a `pcall` (protected call) to prevent Neovim from crashing during startup.

```lua
local ok, result = pcall(require, "some_optional_plugin")
if not ok then
  vim.notify("Failed to load plugin: " .. result, vim.log.levels.WARN)
  return
end
```
- **Notifications**: Prefer `vim.notify` over `print()` for communicating warnings or errors to the user.

### 3.7 Performance and Lazy Loading
- Optimize Neovim startup time by leveraging Lazy.nvim's lazy-loading features.
- Avoid placing heavy initialization logic in the main chunk of a plugin file. Defer it to the `config` function, or trigger it via `keys`, `cmd`, `event`, or `ft` (filetype) properties in the Lazy.nvim spec.

### 3.8 Cross-Platform Compatibility
- This configuration handles multiple environments (Windows natively, WSL, macOS/Linux).
- When writing OS-specific code (e.g., path separators, shells, clipboard handlers), verify the environment using `vim.fn.has("wsl") == 1`, `vim.fn.has("win32") == 1`, or `vim.fn.has("mac") == 1` as seen in `lua/config/options.lua`.
- Always use `vim.fn.stdpath("data")`, `vim.fn.stdpath("config")`, etc., rather than hardcoding paths like `~/.config/nvim`.

### 3.9 Overriding LazyVim Defaults
- LazyVim handles many default configurations out-of-the-box (e.g., LSP diagnostics, core keymaps).
- Do not attempt to override these defaults globally in `lua/config/options.lua` or `lua/config/keymaps.lua` as they may be overwritten by lazy-loaded plugins.
- **Best Practice**: Create a new file in `lua/plugins/` (e.g., `lua/plugins/lsp_overrides.lua`) and use the `opts` table to merge your desired settings with the core plugin configurations.

```lua
-- Example: Overriding LSP Diagnostic settings properly
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false, -- Disable inline virtual text
      },
    },
  },
}
```

## 4. Existing Rules Reference
- **.cursorrules**: Not present.
- **Copilot Instructions**: Not present.
- This `AGENTS.md` file acts as the supreme guideline for AI interactions within this repository.
