return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Disable treesitter highlighting in picker to avoid query errors
      opts.picker = opts.picker or {}
      opts.picker.ui = opts.picker.ui or {}
      opts.picker.ui.highlights = false -- Disable treesitter highlights

      return opts
    end,
  },
}
