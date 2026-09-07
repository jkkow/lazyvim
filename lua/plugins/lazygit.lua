return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        -- Reuse LazyBorder for LazyGit's Neovim float and terminal UI borders.
        -- SnacksTerminalBorder remains independent for future terminal-only tuning.
        theme = {
          activeBorderColor = { fg = "LazyBorder", bold = true },
          inactiveBorderColor = { fg = "LazyBorder" },
          searchingActiveBorderColor = { fg = "LazyBorder", bold = true },
        },
        win = {
          wo = {
            winhighlight = "FloatBorder:LazyBorder",
          },
        },
      },
    },
  },
}
