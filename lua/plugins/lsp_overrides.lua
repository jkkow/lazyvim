return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false, -- Disable virtual text
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      },
    },
  },
}
