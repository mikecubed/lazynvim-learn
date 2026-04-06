-- sample.lua — exercise file for Treesitter and config editing lessons

local M = {}

-- Simple counter with reset support
M.counter = 0

function M.increment(amount)
  amount = amount or 1
  M.counter = M.counter + amount
end

function M.reset()
  M.counter = 0
end

function M.get()
  return M.counter
end

-- Nested table: mock plugin spec (similar to LazyVim plugin entries)
M.plugins = {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua", "python", "javascript" },
      highlight = { enable = true },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 500,
    },
  },
}

-- Utility: find a plugin entry by name fragment
function M.find_plugin(name)
  for _, spec in ipairs(M.plugins) do
    if spec[1] and spec[1]:find(name) then
      return spec
    end
  end
  return nil
end

return M
