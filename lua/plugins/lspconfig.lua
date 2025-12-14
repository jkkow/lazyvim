return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = true, -- error message at the end of lines
      signs = true, -- icons after line numbers
      underline = true, -- underline at the error word
      update_in_insert = false, -- off updating error while input
    },
  },
}
