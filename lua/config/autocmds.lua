-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local lazy_ui_border = vim.api.nvim_create_augroup("lazy_ui_border", { clear = true })

local function set_lazy_border_highlight()
  -- Keep this distinct from SnacksTerminalBorder so the Lazy UI and terminal
  -- can use similar colors today while remaining independently customizable.
  vim.api.nvim_set_hl(0, "LazyBorder", { fg = "#89b4fa", bold = true })
end

set_lazy_border_highlight()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = lazy_ui_border,
  callback = set_lazy_border_highlight,
})

vim.api.nvim_create_autocmd("FileType", {
  group = lazy_ui_border,
  pattern = "lazy",
  callback = function(event)
    -- lazy.nvim sets its own winhighlight while opening the float. Schedule
    -- this mapping afterward so only its border uses the dedicated highlight.
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(event.buf) then
        return
      end

      for _, win in ipairs(vim.fn.win_findbuf(event.buf)) do
        if vim.api.nvim_win_is_valid(win) then
          local winhighlight = vim.wo[win].winhighlight
          local separator = winhighlight == "" and "" or ","
          vim.wo[win].winhighlight = winhighlight .. separator .. "FloatBorder:LazyBorder"
        end
      end
    end)
  end,
})
