-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("i", "lk", "<ESC>")
map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })
map("n", "x", '"_x') -- don't yank with x
map("t", "lk", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

------------------------------------------------------------------------------
-- Diagnostic (LSP Error/Warning) Settings
------------------------------------------------------------------------------
-- Show diagnostics in floating window using 'gl'
map("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostics in floating window" })

-- Navigate between diagnostics
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Go to previous diagnostic" })
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Go to next diagnostic" })

-- Open diagnostic location list
map("n", "gL", vim.diagnostic.setloclist, { desc = "Open diagnostic location list" })

if vim.env.SSH_TTY then
  vim.keymap.set({ "n", "v" }, "<leader>y", function()
    -- Read contents from the active register
    local lines = vim.fn.getreg(vim.v.register)

    if lines ~= "" then
      -- Send text through OSC 52 so remote SSH sessions can copy locally
      local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
      if ok then
        osc52.copy("+")(vim.fn.split(lines, "\n"), "v")
        print("Copied to local clipboard!")
      else
        vim.notify("OSC52 clipboard provider is unavailable", vim.log.levels.WARN)
      end
    else
      print("Nothing to copy!")
    end
  end, { desc = "Copy to Local (OSC 52)" })
end
