-- Options for the lazynvim-learn tutorial sandbox
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = true
opt.scrolloff = 8
opt.confirm = true       -- confirm before closing unsaved buffers
opt.undofile = true
opt.swapfile = false      -- no swap files in tutorial
opt.updatetime = 250

-- Disable clipboard integration (tutorial uses registers)
opt.clipboard = ""

-- Disable the startup dashboard so nvim opens to a plain buffer.
-- The tutorial engine controls what appears in each exercise.
vim.g.snacks_dashboard = false

-- Disable automatic TreeSitter parser and Mason tool installation.
-- These block startup and RPC for minutes on first run.
vim.g.ts_auto_install = false
