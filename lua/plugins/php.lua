return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          settings = {
            intelephense = {
              licenceKey = "00MLLHDKS7PABFP",
            },
          },
        },
      },
    },
  },
  {
    "adibhanna/laravel.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>la", ":Artisan<cr>", desc = "Laravel Artisan" },
      { "<leader>lc", ":Composer<cr>", desc = "Composer" },
      { "<leader>lr", ":LaravelRoute<cr>", desc = "Laravel Routes" },
      { "<leader>lm", ":LaravelMake<cr>", desc = "Laravel Make" },
    },
    config = function()
      require("laravel").setup({
        notifications = true,
        debug = false,
        keymaps = {
          artisan = "<leader>la",
          composer = "<leader>lc",
          route = "<leader>lr",
          make = "<leader>lm",
        },

        sail = {
          enabled = true,
          auto = true,
        },
      })
    end,
  },
  {
    "saghen/blink.nvim",
    opts = {
      sources = {
        default = { "laravel", "lsp", "path", "snippets", "buffer" },
        providers = {
          laravel = {
            name = "laravel",
            module = "laravel.blink_source",
          },
        },
      },
    },
  },
  {
    "ricardoramirezr/blade-nav.nvim",
    dependencies = { -- totally optional
      "hrsh7th/nvim-cmp", -- if using nvim-cmp
      { "ms-jpq/coq_nvim", branch = "coq" }, -- if using coq
      "saghen/blink.cmp", -- if using blink.cmp
    },
    ft = { "blade", "php" }, -- optional, improves startup time
    opts = {
      -- This applies for nvim-cmp and coq, for blink refer to the configuration of this plugin
      close_tag_on_complete = true, -- default: true
    },
  },
}
