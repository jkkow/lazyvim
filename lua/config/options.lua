local opt = vim.opt

-- 1. Shell Setup
-- Set the shell to bash to ensure consistency in the WSL environment
opt.shell = "/bin/bash"
opt.shellcmdflag = "-c"
opt.shellquote = ""
opt.shellxquote = ""

-- Configure shell redirection and piping for external commands
opt.shellredir = ">%s 2>&1"
opt.shellpipe = "2>%1 | tee"

-- 2. Indentation Setup
opt.expandtab = true   -- Convert tabs to spaces
opt.tabstop = 2        -- Insert 2 spaces for a tab
opt.shiftwidth = 2     -- Number of spaces to use for each step of (auto)indent
opt.softtabstop = 2    -- Number of spaces that a <Tab> counts for while editing
opt.autoindent = true  -- Copy indent from current line when starting a new one
opt.breakindent = true -- Preserve indentation in wrapped text

-- 3. UI/UX Setup
-- Keep minimal number of screen lines above and below the cursor
opt.scrolloff = 15

-- 4. WSL Clipboard Setup
-- Configure clipboard to use Windows system clipboard (clip.exe) in WSL.
-- This resolves issues with xclip crashing or freezing.
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      -- Use PowerShell to get clipboard content and remove Carriage Return (`\r`) characters
      ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end

-- Sync with system clipboard
opt.clipboard = "unnamedplus" -- need xclip when Linux environment
