# Agentic Coding Guidelines (AGENTS.md)

This document provides instructions for AI coding agents (like Copilot, Cursor, Opencode, or custom agents) operating within this Neovim configuration repository. It serves as the single source of truth for building, linting, formatting, testing, and stylistic guidelines.

## 1. Environment & Architecture

- **Project Type**: Neovim Configuration.
- **Base Framework**: LazyVim.
- **Language**: Lua 5.1 / LuaJIT (native to Neovim).
- **Package Manager**: `lazy.nvim`.
- **Environment**: Windows (`pwsh` is the default shell for tool execution).
- **AI Assistant**: `opencode.nvim` (configured via `lua/plugins/opencode.lua`).

Agents should strive to respect the LazyVim architecture. Do not override core LazyVim defaults entirely unless instructed; instead, use the `opts` table in plugin specs to cleanly merge user settings with LazyVim defaults.

## 2. Build, Lint, and Test Commands

### 2.1 Building and Running
Since this is a Neovim configuration, there is no formal "build" step.
- **Apply Changes**: Changes to Lua files take effect immediately upon restarting Neovim (`nvim`).
- **Hot Reloading**: Some modules can be hot-reloaded via `:luafile %`, but a full restart is the safest way to verify state.

### 2.2 Formatting
The project uses `stylua` as the official formatter. The `stylua.toml` enforces 2-space indentation and 120-col width.
- **Check formatting**: `stylua --check .`
- **Format codebase**: `stylua .`
- **Format single file**: `stylua path/to/file.lua` (Always run this after modifying a file).

### 2.3 Linting
The Lua Language Server (`lua_ls`) is the primary linter used within Neovim. Diagnostics and workspace settings are configured via `.luarc.json` (disables `undefined-global` for Neovim's `vim` global) and `.neoconf.json`. Agents should read these configs to understand the typing environment.

### 2.4 Testing
Currently, this Neovim configuration does not utilize a formal test suite (like `plenary.busted`). Testing is mostly manual. However, if `plenary.nvim` based tests are added in the future (typically placed in a `tests/` directory), agents **MUST** use the following commands:
- **Run all tests**: `nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"`
- **Run a single test file (CRITICAL for iterative development)**: `nvim --headless -c "PlenaryBustedFile tests/my_spec.lua"`

## 3. Code Style & Best Practices

### 3.1 File Structure
Adhere to the standard LazyVim directory layout:
- `lua/config/options.lua`: Core Neovim options (`vim.opt`, `vim.g`).
- `lua/config/keymaps.lua`: Global keybindings (`vim.keymap.set`).
- `lua/config/autocmds.lua`: Global autocommands (`vim.api.nvim_create_autocmd`).
- `lua/plugins/*.lua`: Plugin specs. Return a table of Lazy.nvim specs.
- `lua/after/ftplugin/*.lua`: Filetype-specific configurations (e.g., `python.lua`).

### 3.2 Scope and Variables
- **Locals First**: Always declare variables and functions as `local`. Never pollute the global `_G` namespace unless absolutely necessary.
- **Imports**: Use `require("module_name")` to load modules. If a module is used multiple times, cache it locally: `local my_module = require("module_name")`. Avoid circular dependencies.

### 3.3 Formatting Details
- **Indentation**: 2 spaces. Never use tabs.
- **Strings**: Double quotes (`"`) are preferred. Single quotes (`'`) are acceptable if the string contains double quotes.
- **Trailing Commas**: Always include trailing commas in multi-line tables for cleaner git diffs.

### 3.4 Naming Conventions
- **Variables & Functions**: `snake_case` (e.g., `local my_variable = 1`).
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `local MAX_RETRIES = 3`).
- **Classes/Metatables**: `PascalCase` if implementing OOP patterns in Lua (e.g., `local MyPlugin = {}`).

### 3.5 Type Annotations
Use EmmyLua annotations to provide type safety and enhance `lua_ls`.
- Annotate function parameters (`---@param`) and return types (`---@return`).
- Define complex tables using `---@class` and `---@field`.

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
- **Protected Calls**: When executing functions that might fail (like requiring optional dependencies or OS commands), wrap them in a `pcall` (protected call) to prevent Neovim from crashing during startup.

```lua
local ok, result = pcall(require, "some_optional_plugin")
if not ok then
  vim.notify("Failed to load plugin: " .. result, vim.log.levels.WARN)
  return
end
```
- **Notifications**: Prefer `vim.notify` over `print()` for communicating warnings or errors.

### 3.7 Performance and Lazy Loading
- Optimize Neovim startup time by leveraging Lazy.nvim's lazy-loading features.
- Avoid placing heavy initialization logic in the main chunk of a plugin file. Defer it to the `config` function, or trigger it via `keys`, `cmd`, `event`, or `ft` properties in the spec.

### 3.8 Cross-Platform Compatibility
- This configuration handles multiple environments (Windows natively, WSL, macOS/Linux).
- When writing OS-specific code (e.g., paths, shells), verify the environment using `vim.fn.has("win32") == 1` or `vim.fn.has("mac") == 1`.
- Always use `vim.fn.stdpath("data")`, `vim.fn.stdpath("config")`, etc., rather than hardcoding paths like `~/.config/nvim`.

### 3.9 Overriding LazyVim Defaults
- Do not attempt to override core LazyVim defaults globally in `lua/config/options.lua` or `lua/config/keymaps.lua` as lazy-loaded plugins may overwrite them.
- **Best Practice**: Create a new file in `lua/plugins/` (e.g., `lua/plugins/lsp_overrides.lua`) and use `opts` to merge settings.

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = { diagnostics = { virtual_text = false } },
  },
}
```

## 4. AI Agents & Opencode Integration

- **Opencode**: This repository actively utilizes `opencode.nvim`. Configuration is at `lua/plugins/opencode.lua`.
- **Skills**: Agents operating within this repository should leverage available Opencode skills via the skill tool when workflows match those specific domains. Available skills in this environment include:
  - `make-skill`: Generates a new Opencode skill folder and SKILL.md file.
  - `modern-git-commit`: Creates modern, readable, secure git commit messages.
  - `obsidian-note-creator`: Generates project/session summaries into Obsidian Vault markdown notes.
- **.cursorrules / .cursor/rules/**: Not present.
- **Copilot Instructions (.github/copilot-instructions.md)**: Not present.

This `AGENTS.md` file acts as the supreme guideline for AI interactions within this repository.
