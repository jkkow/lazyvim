local function path_exists(path)
  return path and vim.uv.fs_stat(path) ~= nil
end

local function first_existing(paths)
  for _, path in ipairs(paths) do
    if path_exists(path) then
      return path
    end
  end
end

local function mason_tool(name)
  local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
  return first_existing({
    vim.fs.joinpath(mason_bin, name .. ".cmd"),
    vim.fs.joinpath(mason_bin, name .. ".exe"),
    vim.fs.joinpath(mason_bin, name),
  })
end

local function resolve_python_tool(root_dir, name)
  if root_dir and root_dir ~= "" then
    local local_tool = first_existing({
      vim.fs.joinpath(root_dir, ".venv", "Scripts", name .. ".exe"),
      vim.fs.joinpath(root_dir, ".venv", "Scripts", name .. ".cmd"),
      vim.fs.joinpath(root_dir, ".venv", "bin", name),
    })

    if local_tool then
      return local_tool
    end
  end

  local path_tool = vim.fn.exepath(name)
  if path_tool ~= "" then
    return path_tool
  end

  return mason_tool(name) or name
end

local function use_resolved_cmd(server_opts, command, args)
  server_opts.cmd = function(dispatchers, config)
    local cmd = vim.list_extend({ resolve_python_tool(config.root_dir, command) }, args)
    return vim.lsp.rpc.start(cmd, dispatchers, {
      cwd = config.cmd_cwd,
      env = config.cmd_env,
      detached = config.detached,
    })
  end
end

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "basedpyright", "ruff" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      opts.servers.basedpyright = opts.servers.basedpyright or {}
      use_resolved_cmd(opts.servers.basedpyright, "basedpyright-langserver", { "--stdio" })

      opts.servers.ruff = opts.servers.ruff or {}
      use_resolved_cmd(opts.servers.ruff, "ruff", { "server" })
    end,
  },
}
