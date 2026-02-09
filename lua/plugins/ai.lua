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

  -- OpenCode (OpenAI, Anthropic, etc.)
  {
    "nickjvandyke/opencode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Provider configuration (defaults to snacks.nvim terminal)
        provider = {
          enabled = "snacks", -- Using snacks terminal for consistency with Claude Code
          snacks = {
            -- You can customize terminal settings here
          },
        },
        -- Enable auto-reload when opencode edits files
        events = {
          reload = true,
        },
      }

      -- Required for auto-reload functionality
      vim.o.autoread = true
    end,
    keys = {
      { "<leader>ao", nil, desc = "OpenCode" },

      -- Core commands (similar to Claude Code workflow)
      { "<leader>aoc", function() require("opencode").toggle() end, desc = "Toggle OpenCode", mode = { "n", "t" } },
      {
        "<leader>aoa",
        function() require("opencode").ask("@this: ", { submit = true }) end,
        desc = "Ask OpenCode",
        mode = { "n", "x" },
      },
      { "<leader>aos", function() require("opencode").select() end, desc = "Select Action/Prompt" },

      -- Buffer and selection management
      {
        "<leader>aob",
        function() require("opencode").prompt("@buffer ") end,
        desc = "Add buffer content",
        mode = "n",
      },
      {
        "<leader>aoF",
        function()
          local filepath = vim.fn.expand("%:p")
          if filepath ~= "" then
            require("opencode").prompt("@" .. filepath .. " ")
          else
            vim.notify("No file path for current buffer", vim.log.levels.WARN)
          end
        end,
        desc = "Add file path (@/path)",
        mode = "n",
      },
      {
        "<leader>aov",
        function() require("opencode").prompt("@visible ") end,
        desc = "Add visible text",
        mode = "n",
      },
      {
        "<leader>aoS",
        function() require("opencode").ask("@this ", { submit = true }) end,
        desc = "Send selection",
        mode = "x",
      },

      -- Operator for adding ranges (similar to Claude's context management)
      {
        "go",
        function() return require("opencode").operator("@this ") end,
        desc = "Add range to OpenCode",
        expr = true,
        mode = { "n", "x" },
      },
      {
        "goo",
        function() return require("opencode").operator("@this ") .. "_" end,
        desc = "Add line to OpenCode",
        expr = true,
        mode = "n",
      },

      -- Pre-configured prompts
      { "<leader>aoe", function() require("opencode").prompt("explain") end, desc = "Explain code", mode = { "n", "x" } },
      { "<leader>aor", function() require("opencode").prompt("review") end, desc = "Review code", mode = { "n", "x" } },
      { "<leader>aof", function() require("opencode").prompt("fix") end, desc = "Fix diagnostics", mode = "n" },
      { "<leader>aot", function() require("opencode").prompt("test") end, desc = "Add tests", mode = { "n", "x" } },
      { "<leader>aod", function() require("opencode").prompt("document") end, desc = "Add documentation", mode = { "n", "x" } },
      {
        "<leader>aoi",
        function() require("opencode").prompt("implement") end,
        desc = "Implement",
        mode = { "n", "x" },
      },

      -- Session management
      { "<leader>aon", function() require("opencode").command("session.new") end, desc = "New session" },
      { "<leader>aol", function() require("opencode").command("session.list") end, desc = "List sessions" },
      {
        "<leader>aoq",
        function() require("opencode").command("session.interrupt") end,
        desc = "Interrupt session",
      },

      -- Scrolling (useful when OpenCode is in a terminal)
      {
        "<S-C-u>",
        function() require("opencode").command("session.half.page.up") end,
        desc = "Scroll OpenCode up",
      },
      {
        "<S-C-d>",
        function() require("opencode").command("session.half.page.down") end,
        desc = "Scroll OpenCode down",
      },
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
