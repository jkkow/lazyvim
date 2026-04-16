# Agent Instructions: Neovim Configuration (LazyVim)

Welcome, Agent. This repository contains a Neovim configuration built on top of the LazyVim framework.
Your primary role is to assist with modifying, refactoring, and adding new features to this Neovim setup.
Most editor configuration source code is written in Lua, and the installer subsystem is written in PowerShell.
Please adhere to the following guidelines and instructions to ensure consistency and stability.

---

## 1. Build, Lint, and Test Commands

Because this is a Neovim configuration, there is no traditional "build" step. However, maintaining code quality through formatting, linting, and testing (if applicable) is critical.

### 1.1 Formatting

We enforce formatting using `stylua`. The configuration is defined in the root `stylua.toml` file.

- **Indent Type:** Spaces
- **Indent Width:** 2
- **Column Width:** 120

**Commands:**

- **Check formatting (dry run):**
  `stylua --check lua/`
- **Format a single file:**
  `stylua <absolute_path_to_lua_file>`
- **Format all files in the repository:**
  `stylua lua/`

### 1.2 Linting

We rely on Neovim's LSP (`lua_ls`) for real-time diagnostics.
If you need to verify code statically via terminal, use `luacheck` (if installed globally).

**Commands:**

- **Run Luacheck on a single file:**
  `luacheck <absolute_path_to_lua_file>`
- **Run Luacheck on the entire project:**
  `luacheck lua/`

*Note: The global `vim` is always available and should be ignored by linters. Be cautious not to introduce global leaks (`_G`).*

### 1.3 Testing

Standard Neovim configurations do not strictly require a test suite. However, if working on complex custom Lua modules, `plenary.nvim`'s `busted` framework may be used.

**Commands:**

- **Run all tests (headless mode):**
  `nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"`
- **Run a single test file (headless mode):**
  `nvim --headless -c "PlenaryBustedFile <absolute_path_to_test_file>"`

*(Agent Note: Only attempt to run these test commands if you have verified that a `tests/` or `spec/` directory exists with valid `_spec.lua` files.)*

### 1.4 Applying Changes

Changes to Lua files generally take effect when Neovim is restarted.
For hot-reloading specific modules during active development inside Neovim, the following Lua snippet can be used:
`package.loaded["module.name"] = nil; require("module.name")`

### 1.5 Installer Script Validation (PowerShell)

Installer orchestration and package installers live under `install/` and are PowerShell scripts.

**Commands:**

- **Run installer help (sanity check):**
  `powershell -NoProfile -ExecutionPolicy Bypass -File .\install\install.ps1 -Help`
- **Syntax-check all installer scripts (PowerShell parser):**
  `powershell -NoProfile -Command "$files = Get-ChildItem -Path install -Filter *.ps1 -Recurse; foreach ($f in $files) { $null = $tokens = $errors = $null; [System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$tokens, [ref]$errors) > $null; if ($errors.Count) { $errors | ForEach-Object { Write-Error \"$($f.FullName): $($_.Message)\" } } }"`
- **Optional static analysis (if installed):**
  `Invoke-ScriptAnalyzer -Path install -Recurse`

Installer policy reminders:

- Keep installer behavior **Windows 11-first** unless explicitly requested otherwise.
- Keep minimum version pins centralized in `install/min-required-versions.txt`.
- Preserve sectioned/progress output conventions in `install/install.ps1`.
- When changing installer flow/structure, keep `install/INSTALLATION.md` and `README.md` installation references in sync.

---

## 2. Code Style Guidelines

To maintain a clean and idiomatic codebase, follow these rules strictly.

### 2.1 File Structure and Imports

- **LazyVim Standard:** All plugin specifications must reside in `lua/plugins/`. Avoid clashing with LazyVim defaults unless explicitly intending to override them.
- **Core Config:** Core settings belong in `lua/config/` (e.g., `options.lua`, `keymaps.lua`, `autocmds.lua`).
- **Imports (`require`):**
  - For standard module imports, use standard `require("module_name")`.
  - If a module might not be present (e.g., an optional dependency), use `pcall`:

    ```lua
    local status_ok, module = pcall(require, "module_name")
    if not status_ok then return end
    ```

  - For LazyVim plugin specs, return a Lua table directly:

    ```lua
    return {
      "author/plugin-name",
      opts = {
        -- configuration options here
      },
    }
    ```

### 2.2 Formatting and Syntax

- **Indentation:** Exactly 2 spaces. No tabs.
- **Line Length:** Maximum 120 characters per line.
- **Quotes:** Prefer double quotes (`"`) for standard strings. Use single quotes (`'`) only if it helps avoid escaping double quotes within the string.
- **Semicolons:** Omit semicolons at the end of statements. They are unidiomatic in Lua.
- **Tables:** Always include trailing commas in multi-line tables. This produces much cleaner Git diffs.

### 2.3 Typing and Annotations

We heavily utilize EmmyLua / LCATS annotations to provide context for `lua_ls` (Lua Language Server).
Always annotate function signatures, especially for complex utilities.

**Example:**

```lua
---@class UserOptions
---@field name string The display name
---@field age? number The user's age (optional)

---Validates the user configuration.
---@param opts UserOptions The configuration options
---@return boolean isValid Whether the options are valid
local function validate_opts(opts)
  if not opts.name then return false end
  return true
end
```

### 2.4 Naming Conventions

- **Variables and Functions:** `snake_case` (e.g., `local current_buffer`, `local function get_word()`).
- **Constants:** `UPPER_SNAKE_CASE` (e.g., `local MAX_FILE_SIZE = 1024`).
- **Modules and Classes:** `PascalCase` if acting as an object-oriented class or metatable (e.g., `local MyClass = {}`).
- **Private/Internal Members:** Prefix with an underscore `_` to denote that a variable or function is not meant to be accessed outside its scope (e.g., `local _internal_cache = {}`).

### 2.5 Error Handling

- Never allow an unhandled error to crash the user's Neovim session.
- Use `vim.notify` to surface errors to the user gracefully.
- Wrap risky operations (e.g., file system reads, external commands) in `pcall`.

**Example:**

```lua
local ok, result = pcall(function()
  return vim.fn.readfile("some_file.txt")
end)

if not ok then
  vim.notify("Failed to read file: " .. tostring(result), vim.log.levels.ERROR)
  return nil
end
```

- Only use `error("Message")` for assertions where the module fundamentally cannot load without fulfilling a condition.

### 2.6 Neovim-Specific Practices

- **No Global Leaks:** Do not use `_G` unless absolutely necessary. Always prefix variables with `local`.
- **Keymaps:** Define mappings using `vim.keymap.set()`. Always provide a `desc` string in the options table so that plugins like `which-key.nvim` can pick them up.

  ```lua
  vim.keymap.set("n", "<leader>cx", vim.lsp.buf.rename, { desc = "Rename Symbol" })
  ```

- **Autocmds:** Always place `autocmd`s inside an `augroup` using `clear = true`. This prevents duplicate events if the configuration is sourced multiple times.

  ```lua
  local my_group = vim.api.nvim_create_augroup("MyCustomGroup", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = my_group,
    pattern = { "lua", "python" },
    callback = function()
      vim.opt_local.wrap = true
    end,
  })
  ```

- **Lazy.nvim Config:** Prefer using the `opts` table over the `config` function. Lazy automatically calls `require("plugin").setup(opts)`. Only use `config = function(_, opts)` if you need to run custom logic before or after setup.

### 2.7 Installer Script Style (PowerShell)

- Use `param(...)` blocks and set `$ErrorActionPreference = "Stop"` in installer scripts.
- Dot-source shared helpers from `install/lib/common.ps1` and version helpers from `install/lib/version_requirements.ps1` when needed.
- Keep scripts idempotent: check first, then install only when needed.
- Prefer `Write-LogInfo`, `Write-LogWarn`, `Write-LogError`, and `Write-LogSection` for output consistency.
- Use small, focused scripts (one tool/concern per installer file) and compose via manifests.
- Preserve `post/` fixups for symlink/version verification where applicable.

---

## 3. Tool Rules & Compatibility

- **Context First:** Before proposing or making any changes, use `glob` and `read` to explore the relevant area (`lua/plugins/`, `lua/config/`, or `install/`) to understand existing configurations.
- **Absolute Paths:** When using file system tools, always use Windows absolute paths rooted at `C:\Users\jkkow\.config\nvim\`.
- **No Interactive Shell:** Avoid commands like `nvim` or `git commit -i` that prompt the user or launch TUI applications.
- **LazyVim Upgrades:** Do not try to manually update LazyVim core files. Stick to the designated `lua/plugins/` and `lua/config/` user directories.
- **Installer Scope:** Do not move installer logic into LazyVim core or distro-agnostic abstractions unless explicitly requested; keep installer changes in `install/`.
- **Cursor/Copilot Constraints:** If you find `.cursorrules` or `.github/copilot-instructions.md` in the future, adhere to them alongside these instructions (none exist currently for this repository).
