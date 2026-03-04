return {
  "nickjvandyke/opencode.nvim",
  version = "*", -- Latest stable release
  dependencies = {
    -- Recommended for 'ask()', and required for 'toggle()' -- otherwise optional
    { "folke/snacks.nvim", opts = { input = { enabled = true } } },
  },
  config = function()
    vim.g.opencode_opts = {
      -- Your configuration, if any; goto definition on the type or field for details
    }

    -- Required for `opts.events.reload`
    vim.o.autoread = true

    -- Recommended/example keymaps
    vim.keymap.set({ "n", "t" }, "<leader>ot", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })
    vim.keymap.set({ "n", "t" }, "<leader>oa", function()
      require("opencode").ask("@cursor: ")
    end, { desc = "Opencode ask this" })
    vim.keymap.set({ "v" }, "<leader>oa", function()
      require("opencode").ask("@selection: ")
    end, { desc = "Opencode ask selection" })
    vim.keymap.set({ "n", "x" }, "<leader>og", function()
      return require("opencode").operator("@this ")
    end, { desc = "Add range to opencode", expr = true })
  end,
}
