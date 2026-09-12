local is_windows = vim.uv.os_uname().version:match("Windows")
local base_dir = is_windows and os.getenv("USERPROFILE") .. "\\dev\\neovim\\" or os.getenv("HOME") .. "/dev/neovim/"
-- local vault_path = is_windows and os.getenv("USERPROFILE") .. "\\Documents\\Notes\\"
--   or os.getenv("HOME") .. "/Documents/Notes/"
local dir_exists = vim.uv.fs_stat(base_dir) ~= nil

return {
  {
    "4lexandrei/neobsync.nvim",
    branch = "dev",
    dev = dir_exists,
    dir = dir_exists and base_dir .. "neobsync.nvim" or nil,
    ft = "markdown",
    opts = {
      vault_path = nil,
      HOST = "127.0.0.1",
      PORT = 9000,
    },
  },
}
