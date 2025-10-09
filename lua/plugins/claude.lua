return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<leader>a", nil, desc = "AI" },

    { "<leader>ac", nil, desc = "Claude" },

    { "<leader>acc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>acf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>acr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aco", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },

    { "<leader>acm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Model" },

    { "<leader>acb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    {
      "<leader>acf",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file from tree",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
    },

    { "<leader>acs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },

    { "<leader>aca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>acd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
