return {
  -- Markdown preview in terminal using glow
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    ft = { "markdown" },
    keys = {
      { "<leader>mp", "<cmd>Glow<cr>", desc = "Markdown Preview (Glow)" },
    },
    opts = {
      border = "rounded",
      style = "dark",
      width = 120,
      height = 100,
      width_ratio = 0.8,
      height_ratio = 0.8,
    },
  },

  -- Alternative: Render markdown inline in the buffer
  -- Temporarily disabled due to treesitter conflicts
  -- {
  --   "MeanderingProgrammer/render-markdown.nvim",
  --   ft = { "markdown" },
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   keys = {
  --     { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Render" },
  --   },
  --   opts = {
  --     headings = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
  --     code = {
  --       enabled = true,
  --       sign = true,
  --       style = "full",
  --       width = "block",
  --       left_pad = 2,
  --       right_pad = 2,
  --     },
  --   },
  -- },
}
