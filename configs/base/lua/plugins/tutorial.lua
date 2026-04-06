return {
  {
    name = "lazynvim-learn",
    dir = vim.fn.stdpath("config") .. "/lua/lazynvim-learn",
    lazy = false,
    priority = 1000,
    config = function()
      -- Companion plugin for the tutorial engine
      -- No keymaps, no UI — this is a headless support plugin
    end,
  },

  -- Disable all startup dashboard plugins so exercises open to a plain buffer
  { "nvimdev/dashboard-nvim", enabled = false },
  { "goolord/alpha-nvim", enabled = false },
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },
}
