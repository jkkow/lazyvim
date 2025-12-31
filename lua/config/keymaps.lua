-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("i", "lk", "<ESC>")
map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" }) -- Selett all
map("n", "x", '"_x') -- don't yank with x
