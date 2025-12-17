return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "php",
        "php_only",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "elixir",
        "heex",
        "blade",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "blade" },
      },
      indent = {
        enable = true,
      },
      injections = {
        enable = true,
      },
    },
  },
  {
    "EmranMR/tree-sitter-blade",
    requires = { "nvim-treesitter/nvim-treesitter" },
  },
}
