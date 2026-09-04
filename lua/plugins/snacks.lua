-- Walk up through nested git submodules until reaching the outermost superproject.
-- Without this, LazyVim's root detection stops at the submodule's own `.git`,
-- so searching from a file inside a submodule never sees the rest of the repo.
local function superproject_root()
  local root = LazyVim.root()
  local dir = root
  for _ = 1, 10 do
    local out = vim.system(
      { "git", "-C", dir, "rev-parse", "--show-superproject-working-tree" },
      { text = true }
    ):wait()
    local parent = vim.trim(out.stdout or "")
    if out.code ~= 0 or parent == "" then
      break
    end
    dir = parent
  end
  return dir ~= "" and dir or root
end

local function find_files()
  -- `rg`/`fd` already descend into submodule directories, so scoping the search
  -- at the superproject is enough to include them.
  Snacks.picker.files({ cwd = superproject_root() })
end

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
    -- stylua: ignore
    keys = {
      { "<leader><space>", find_files, desc = "Find Files (Root Dir + submodules)" },
      { "<leader>ff", find_files, desc = "Find Files (Root Dir + submodules)" },
    },
  },
}
