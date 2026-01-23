return {
  -- Claude Code
  {
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
        "<leader>act",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file from tree",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
      },
      { "<leader>acs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
      { "<leader>aca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>acd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },

  -- Gemini CLI
  {
    "marcinjahn/gemini-cli.nvim",
    cmd = "Gemini",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>ag", nil, desc = "Gemini" },
      { "<leader>agg", "<cmd>Gemini toggle<cr>", desc = "Toggle Gemini CLI" },
      { "<leader>aga", "<cmd>Gemini ask<cr>", desc = "Ask Gemini", mode = { "n", "v" } },
      { "<leader>agb", "<cmd>Gemini add_file<cr>", desc = "Add current buffer" },
    },
  },

  -- GitHub Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {},
    keys = {
      { "<leader>ap", nil, desc = "Copilot" },
      { "<leader>app", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" },
      { "<leader>apa", "<cmd>CopilotChatExplain<cr>", desc = "Ask Copilot (Explain)" },
      { "<leader>apr", "<cmd>CopilotChatReview<cr>", desc = "Code Review" },
      { "<leader>apf", "<cmd>CopilotChatFix<cr>", desc = "Fix Issue" },
      { "<leader>aps", "<cmd>CopilotChatSend<cr>", mode = "v", desc = "Send selection" },
      { "<leader>apb", "<cmd>CopilotChatAddBuffer<cr>", desc = "Add current buffer" },
    },
  },
}
