-- Treesitter parser directory (where compiled .so files live)
local parser_install_dir = vim.fn.stdpath("data") .. "/site/parser"

--- Remove a single parser .so file and reinstall it
---@param lang string
local function fix_parser(lang)
  local parser_path = parser_install_dir .. "/" .. lang .. ".so"
  if vim.fn.filereadable(parser_path) == 1 then
    vim.fn.delete(parser_path)
  end
  -- Reinstall via nvim-treesitter
  vim.cmd("TSInstall " .. lang)
end

--- Remove ALL compiled parsers and reinstall everything from ensure_installed
local function fix_all_parsers()
  local files = vim.fn.glob(parser_install_dir .. "/*.so", false, true)
  for _, f in ipairs(files) do
    vim.fn.delete(f)
  end
  vim.notify("Deleted " .. #files .. " parser(s). Reinstalling...", vim.log.levels.INFO)
  vim.cmd("TSUpdate")
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      -- Wipe stale parsers before rebuilding to prevent query mismatch errors
      local files = vim.fn.glob(parser_install_dir .. "/*.so", false, true)
      for _, f in ipairs(files) do
        vim.fn.delete(f)
      end
      -- Standard treesitter update
      vim.cmd("TSUpdate")
    end,
    opts = {
      ensure_installed = {
        "bash",
        "css",
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
        "vimdoc",
        "yaml",
        "elixir",
        "heex",
        "blade",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "blade" },
        disable = function(lang, buf)
          -- Disable highlighting for very large files to avoid performance issues
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
          return false
        end,
      },
      indent = {
        enable = true,
      },
      injections = {
        enable = true,
      },
    },
    init = function()
      -- User commands for manual parser management (available before plugin loads)
      vim.api.nvim_create_user_command("TSFixParsers", function()
        fix_all_parsers()
      end, { desc = "Delete all compiled treesitter parsers and reinstall" })

      vim.api.nvim_create_user_command("TSFixParser", function(cmd_opts)
        if cmd_opts.args == "" then
          vim.notify("Usage: :TSFixParser <lang>", vim.log.levels.ERROR)
          return
        end
        fix_parser(cmd_opts.args)
      end, {
        nargs = 1,
        desc = "Delete and reinstall a single treesitter parser",
        complete = function()
          -- Complete with installed parser names
          local files = vim.fn.glob(parser_install_dir .. "/*.so", false, true)
          local langs = {}
          for _, f in ipairs(files) do
            table.insert(langs, vim.fn.fnamemodify(f, ":t:r"))
          end
          return langs
        end,
      })

      -- Auto-detect treesitter query errors and offer to fix
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ts_query_error_handler", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
          local query_ok = pcall(vim.treesitter.query.get, lang, "highlights")
          if not query_ok then
            vim.notify(
              string.format("Treesitter query error for '%s'. Run :TSFixParser %s to fix.", lang, lang),
              vim.log.levels.WARN
            )
          end
        end,
      })
    end,
  },
  {
    "EmranMR/tree-sitter-blade",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
