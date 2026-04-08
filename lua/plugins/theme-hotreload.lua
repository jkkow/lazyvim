return {
  {
    name = "theme-hotreload",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      local colorscheme_module = "plugins.colorscheme"
      local transparency_file = vim.fn.stdpath("config") .. "/plugin/after/transparency.lua"

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyReload",
        callback = function()
          package.loaded[colorscheme_module] = nil

          vim.schedule(function()
            local ok, theme_spec = pcall(require, colorscheme_module)
            if not ok or type(theme_spec) ~= "table" then
              return
            end

            local colorscheme
            for _, spec in ipairs(theme_spec) do
              if spec[1] == "LazyVim/LazyVim" and spec.opts and spec.opts.colorscheme then
                colorscheme = spec.opts.colorscheme
                break
              end
            end

            if not colorscheme then
              return
            end

            vim.cmd("highlight clear")
            if vim.fn.exists("syntax_on") == 1 then
              vim.cmd("syntax reset")
            end

            require("lazy.core.loader").colorscheme(colorscheme)

            vim.defer_fn(function()
              pcall(vim.cmd.colorscheme, colorscheme)

              if vim.fn.filereadable(transparency_file) == 1 then
                vim.cmd.source(transparency_file)
              end

              vim.api.nvim_exec_autocmds("ColorScheme", { modeline = false })
              vim.cmd("redraw!")
            end, 10)
          end)
        end,
      })
    end,
  },
}
