local function path_exists(path)
  return path and vim.uv.fs_stat(path) ~= nil
end

local function executable_path(path)
  if path_exists(path) then
    return path
  end
end

local function resolve_panache(root_dir)
  local candidates = {}

  if root_dir and root_dir ~= "" then
    candidates = {
      vim.fs.joinpath(root_dir, "node_modules", ".bin", "panache.cmd"),
      vim.fs.joinpath(root_dir, "node_modules", ".bin", "panache.exe"),
      vim.fs.joinpath(root_dir, "node_modules", ".bin", "panache"),
      vim.fs.joinpath(root_dir, ".venv", "Scripts", "panache.exe"),
      vim.fs.joinpath(root_dir, ".venv", "Scripts", "panache.cmd"),
      vim.fs.joinpath(root_dir, ".venv", "bin", "panache"),
    }
  end

  for _, candidate in ipairs(candidates) do
    local resolved = executable_path(candidate)
    if resolved then
      return resolved
    end
  end

  local path_panache = vim.fn.exepath("panache")
  if path_panache ~= "" then
    return path_panache
  end

  local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
  local mason_candidates = {
    vim.fs.joinpath(mason_bin, "panache.cmd"),
    vim.fs.joinpath(mason_bin, "panache.exe"),
    vim.fs.joinpath(mason_bin, "panache"),
  }

  for _, candidate in ipairs(mason_candidates) do
    local resolved = executable_path(candidate)
    if resolved then
      return resolved
    end
  end

  return "panache"
end

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "panache" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local util = require("lspconfig.util")

      opts.servers = opts.servers or {}
      opts.setup = opts.setup or {}

      opts.servers.marksman = { enabled = false }
      opts.servers.panache = vim.tbl_deep_extend("force", opts.servers.panache or {}, {
        cmd = { "panache", "lsp" },
        filetypes = { "markdown", "quarto", "rmarkdown" },
        root_markers = { ".panache.toml", "panache.toml", "_quarto.yml", ".quarto", ".git" },
        root_dir = function(fname)
          return util.root_pattern(".panache.toml", "panache.toml", "_quarto.yml", ".quarto", ".git")(fname)
            or util.path.dirname(fname)
        end,
        on_new_config = function(config, root_dir)
          config.cmd = { resolve_panache(root_dir), "lsp" }
        end,
      })

      opts.setup.panache = function(_, server_opts)
        local lspconfig = require("lspconfig")
        local configs = require("lspconfig.configs")

        if not configs.panache then
          configs.panache = {
            default_config = {
              cmd = { "panache", "lsp" },
              filetypes = { "markdown", "quarto", "rmarkdown" },
              root_dir = util.root_pattern(".panache.toml", "panache.toml", "_quarto.yml", ".quarto", ".git"),
              single_file_support = true,
            },
          }
        end

        lspconfig.panache.setup(server_opts)
        return true
      end
    end,
  },
  {
    "LazyVim/LazyVim",
    init = function()
      vim.filetype.add({
        extension = {
          qmd = "quarto",
          rmd = "rmarkdown",
          Rmd = "rmarkdown",
        },
      })
    end,
  },
}
