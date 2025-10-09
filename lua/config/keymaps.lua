-- Keymaps are automatically loaded on the VeryLazy event
--
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Smart navigation function for Inertia.js and Blade views
local function smart_goto_definition()
  local word = vim.fn.expand("<cword>")
  local current_file = vim.fn.expand("%:p")
  local line = vim.api.nvim_get_current_line()
  
  -- Try LSP go-to-definition first
  local clients = vim.lsp.get_active_clients()
  if #clients > 0 then
    -- Check if we're in a context where we want to override LSP
    local is_inertia_render = line:match("Inertia::render") or line:match("inertia%(")
    local is_view_call = line:match("view%(") or line:match("@extends") or line:match("@include")
    
    if not (is_inertia_render or is_view_call) then
      vim.lsp.buf.definition()
      return
    end
  end
  
  -- Enhanced Inertia.js navigation - extract path from Inertia::render call
  local inertia_path = nil
  
  -- Check if cursor is on an Inertia::render line
  if line:match("Inertia::render") then
    -- Extract the path from Inertia::render('path', ...)
    local path_match = line:match("Inertia::render%s*%(%s*['\"]([^'\"]+)['\"]")
    if path_match then
      inertia_path = path_match
    end
  end
  
  -- If we found an Inertia path, use it; otherwise use the word under cursor
  local target_path = inertia_path or word
  
  -- Inertia.js page navigation - try multiple extensions and paths
  local inertia_paths = {
    "resources/js/Pages/" .. target_path .. ".tsx",
    "resources/js/Pages/" .. target_path .. ".vue", 
    "resources/js/Pages/" .. target_path .. ".jsx",
    "resources/js/pages/" .. target_path .. ".tsx",
    "resources/js/pages/" .. target_path .. ".vue",
    "resources/js/pages/" .. target_path .. ".jsx"
  }
  
  for _, path in ipairs(inertia_paths) do
    if vim.fn.filereadable(path) == 1 then
      vim.cmd("edit " .. path)
      return
    end
  end
  
  -- Blade view navigation
  local view_paths = {
    "resources/views/" .. target_path:gsub("%.", "/") .. ".blade.php",
    "resources/views/" .. target_path:lower():gsub("%.", "/") .. ".blade.php"
  }
  
  for _, path in ipairs(view_paths) do
    if vim.fn.filereadable(path) == 1 then
      vim.cmd("edit " .. path)
      return
    end
  end
  
  -- If nothing found, show error
  vim.notify("Could not find Inertia page or Blade view: " .. target_path, vim.log.levels.WARN)
end

vim.keymap.set("n", "gd", smart_goto_definition, { desc = "Smart go to definition (LSP/Inertia/Blade)" })

-- Laravel quick navigation
vim.keymap.set("n", "<leader>le", ":edit .env<cr>", { desc = "Open .env file" })
vim.keymap.set("n", "<leader>ll", ":edit storage/logs/laravel.log<cr>", { desc = "Open Laravel log file" })
