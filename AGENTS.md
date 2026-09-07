# AGENTS Guide for `~/.config/nvim`

This repository is a cross-platform Neovim config based on LazyVim.
Most code is Lua under `lua/`.

Use this file as the default operating guide for coding agents.

---

## 1) Repository Map (What Lives Where)

- `lua/config/`: base user config (`options.lua`, `platform.lua`, `keymaps.lua`, `autocmds.lua`, `lazy.lua`)
- `lua/plugins/`: plugin specs and plugin overrides
- `lua/after/ftplugin/`: filetype-local behavior
- `stylua.toml`: canonical Lua formatting settings

Do not edit LazyVim upstream internals directly; prefer user overrides in `lua/config/` and `lua/plugins/`.

---

## 2) Build / Lint / Test Commands

There is no traditional compile/build step for this repo.
Validation is formatting + lint-like checks + Neovim smoke/test runs.

### 2.1 Formatting (Lua)

- Check format (no write):
  - `stylua --check lua/`
- Format all Lua files:
  - `stylua lua/`
- Format a single file:
  - `stylua "C:\Users\jkko\.config\nvim\lua\plugins\<file>.lua"`

Formatting source of truth (`stylua.toml`):
- spaces, width 2
- max column 120

### 2.2 Lint / Diagnostics

Primary diagnostics are from `lua_ls` inside Neovim.
If available in shell, use `luacheck` as an extra check.

- Lint all Lua files:
  - `luacheck lua/`
- Lint one file:
  - `luacheck "C:\Users\jkko\.config\nvim\lua\config\keymaps.lua"`

### 2.3 Tests (especially single-test command)

This repository currently has no committed `tests/` or `spec/` tree.
If tests are added later (Plenary/Busted style), use:

- Run all tests:
  - `nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"`
- Run a single test file:
  - `nvim --headless -c "PlenaryBustedFile C:/Users/jkko/.config/nvim/tests/<name>_spec.lua"`

Only run these when the referenced test files exist.

### 2.4 Cross-platform Git policy

- Before making any changes, verify the current branch is not behind its `origin` upstream:
  - `git fetch origin`
  - `git rev-list --left-right --count 'HEAD...@{upstream}'`
  - Proceed only when the second count (commits behind) is `0`.
  - If the branch is behind, tell the user and stop. Do not pull, merge, or rebase without explicit approval.
- Validate line endings and whitespace:
  - `git ls-files --eol`
  - `git diff --check`
  - `git diff --cached --check`

---

## 3) Code Style Rules (Lua)

### 3.1 Imports and Module Layout

- Use `local mod = require("module")` for required dependencies.
- Use guarded imports for optional deps:
  - `local ok, mod = pcall(require, "module")`
  - `if not ok then return end`
- Keep plugin definitions in `lua/plugins/*.lua` returning tables.
- Keep core editor behavior in `lua/config/*.lua`.

### 3.2 Formatting and Syntax

- Indentation: 2 spaces, no tabs.
- Line length: target <= 120 columns.
- Prefer double quotes in Lua strings.
- Avoid semicolons.
- Use trailing commas in multiline tables.

### 3.3 Types / Annotations

- Prefer EmmyLua/`lua_ls` annotations for non-trivial modules.
- Document function params/returns for utilities with branching logic.
- Keep annotations accurate when refactoring function signatures.

### 3.4 Naming Conventions

- Variables/functions: `snake_case`
- Constants: `UPPER_SNAKE_CASE`
- Module tables acting as classes: `PascalCase` (when used)
- Internal-only helpers may use leading underscore when helpful

### 3.5 Error Handling

- Do not crash Neovim for recoverable failures.
- Wrap risky calls with `pcall`.
- Use `vim.notify(..., vim.log.levels.ERROR)` for user-visible failures.
- Return early on optional-feature failures instead of hard erroring.
- Reserve `error(...)` for truly unrecoverable module-init invariants.

### 3.6 Neovim/LazyVim Practices

- Prefer `local` scope; avoid leaking globals.
- Keymaps: use `vim.keymap.set` and include `desc`.
- Autocmds: group with `nvim_create_augroup(..., { clear = true })`.
- For lazy.nvim specs, prefer `opts = {}` over `config = function()` when possible.
- Keep overrides minimal and intentional to reduce drift from LazyVim defaults.

---

## 4) Agent Workflow Expectations

- Read nearby files before editing; follow established local patterns.
- Prefer small, surgical changes over broad rewrites.
- Do not introduce unrelated refactors in the same patch.
- Validate changed files with relevant commands from Section 2.
- Keep platform-specific behavior isolated behind `lua/config/platform.lua`.

---

## 5) Cursor / Copilot Rules

Checked in this repository:
- `.cursor/rules/`: not present
- `.cursorrules`: not present
- `.github/copilot-instructions.md`: not present

If any of these files are added later, treat them as additional mandatory constraints.
