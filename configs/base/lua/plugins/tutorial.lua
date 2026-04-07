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

  -- Disable automatic installs that block startup and RPC
  { "nvim-treesitter/nvim-treesitter", opts = { auto_install = false } },
  { "mason-org/mason.nvim", opts = { auto_install = false } },
  { "mason-org/mason-lspconfig.nvim", opts = { automatic_installation = false } },

  -- Ensure tutorial-required tools are installed via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "ruff",
        "pyright",
        "lua-language-server",
        "debugpy",
      })
    end,
  },

  -- Configure ruff as Python formatter (the lang.python extra may not load correctly)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
      },
    },
  },
}
