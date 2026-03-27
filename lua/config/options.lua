-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

------------------------------------------------------------------------------
-- 1. Common Settings (Indentation & UI)
-- These settings apply to all environments (WSL, Windows, Linux)
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

if vim.fn.has("wsl") == 1 then
  -- [ Case A: WSL Environment ]
  -- Use /bin/bash as the default shell
  opt.shell = "/bin/bash"
  opt.shellcmdflag = "-c"
  opt.shellquote = ""
  opt.shellxquote = ""
  opt.shellredir = ">%s 2>&1"
  opt.shellpipe = "2>%1 | tee"

  -- WSL Clipboard Fix: Force use of Windows clip.exe to prevent xclip crashes
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
elseif vim.fn.has("win32") == 1 then
  -- [ Case B: Native Windows Environment ]
  -- Use PowerShell Core (pwsh) as the default shell
  opt.shell = "pwsh"

  -- PowerShell flags for correct encoding (UTF-8) and execution
  opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  opt.shellquote = ""
  opt.shellxquote = ""
else
  -- [ Case C: Pure Linux / macOS ]
  -- Default shell settings (usually bash or zsh)
  -- If you need specific settings for Mac, add them here.
end

-- Sync clipboard between OS and Neovim (Applies to all)
opt.clipboard = "unnamedplus"

------------------------------------------------------------------------------
-- 3. Display Settings (Wrap & Linebreak)
------------------------------------------------------------------------------
opt.wrap = true -- Wrap long lines
opt.linebreak = true -- Wrap at word boundaries
