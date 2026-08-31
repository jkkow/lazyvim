local has = vim.fn.has

local is_wsl = has("wsl") == 1
local is_windows = not is_wsl and has("win32") == 1
local is_macos = has("macunix") == 1

return {
  is_wsl = is_wsl,
  is_windows = is_windows,
  is_macos = is_macos,
  is_linux = not is_wsl and not is_macos and has("unix") == 1,
  is_unix = has("unix") == 1,
}
