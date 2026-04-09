-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("i", "lk", "<ESC>")
map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" }) -- Selett all
map("n", "x", '"_x') -- don't yank with x

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

-- lua/config/keymaps.lua
if vim.env.SSH_TTY then
  vim.keymap.set({ "n", "v" }, "<leader>y", function()
    -- Bring activated register contents
    local lines = vim.fn.getreg(vim.v.register)

    if lines ~= "" then
      -- Transform refined contents to local terminal through OSC 52
      require("vim.ui.clipboard.osc52").copy("+")(vim.fn.split(lines, "\n"), "v")
      print("Copied to local clipboard!")
    else
      print("Nothing to copy!")
    end
  end, { desc = "Copy to Local (OSC 52)" })
end
