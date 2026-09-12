-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.clipboard = "unnamedplus"
vim.opt.conceallevel = 0
vim.opt.showmode = false
-- vim.opt.scrolloff = 999

-- vim.opt.hidden = false -- Prevent switching away from a buffer with unsaved changes

-- Prevent lsp to change root directory when using <leader>space
vim.g.root_spec = { "cwd" }

-- Custom vim globals
vim.g.signature = "blink" -- "blink" | "noice" as signature provider

vim.lsp.log.set_level("off") -- Prevents large size lsp log file
