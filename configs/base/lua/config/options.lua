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
