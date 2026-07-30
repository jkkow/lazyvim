-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LazyVim's Python extra reads these globals while plugin specs are being built.
-- Keep them here so the extra enables BasedPyright instead of its default Pyright
-- before lua/plugins/python-lsp.lua applies the project-local command resolver.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

local opt = vim.opt

------------------------------------------------------------------------------
-- 1. Common Settings (Indentation & UI)
-- Baseline settings for Windows 11 Neovim usage
------------------------------------------------------------------------------

-- Indentation Setup
opt.expandtab = true -- Convert tabs to spaces
opt.tabstop = 2 -- Insert 2 spaces for a tab
opt.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent
opt.softtabstop = 2 -- Number of spaces that a <Tab> counts for while editing
opt.autoindent = true -- Copy indent from current line when starting a new one
opt.breakindent = true -- Preserve indentation in wrapped text

-- UI/UX Setup
opt.scrolloff = 15 -- Keep minimal number of screen lines above and below the cursor

------------------------------------------------------------------------------
-- 2. Environment Specific Setup (Shell & Clipboard)
------------------------------------------------------------------------------

-- Sync clipboard between Windows and Neovim
-- On Windows 11, Neovim uses the native clipboard provider
opt.clipboard = "unnamedplus"

------------------------------------------------------------------------------
-- 3. Display Settings (Wrap & Linebreak)
------------------------------------------------------------------------------
opt.wrap = true -- Wrap long lines
opt.linebreak = true -- Wrap at word boundaries

-- GUI font for Windows Neovim clients (Neovide, nvim-qt, etc.)
if vim.fn.has("win32") == 1 then
  opt.guifont = "JetBrainsMono Nerd Font:h11"
  if vim.fn.executable("pwsh") == 1 then
    opt.shell = "pwsh"

    opt.shellcmdflag = table.concat({
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy RemoteSigned",
      "-Command",
      "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
    }, " ")
    opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    opt.shellquote = ""
    opt.shellxquote = ""
  end
end
