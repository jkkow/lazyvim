return {
  -- 1. Install a plugin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },

  -- 2. Overwrite LazyVim core option
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
