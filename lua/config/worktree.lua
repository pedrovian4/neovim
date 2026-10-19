-- Git worktree management integrated with claudecode.nvim.
-- Worktrees live in <repo-parent>/<repo>.worktrees/<branch>, same layout as the fish `gw` command.
local M = {}

local function git(args, cwd)
  local cmd = { "git" }
  if cwd then
    vim.list_extend(cmd, { "-C", cwd })
  end
  vim.list_extend(cmd, args)
  local out = vim.system(cmd, { text = true }):wait()
  return out.code == 0, vim.trim(out.stdout or ""), vim.trim(out.stderr or "")
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Worktree" })
end

---@return {path: string, branch: string}[]
function M.list()
  local ok, out = git({ "worktree", "list", "--porcelain" })
  if not ok then
    return {}
  end
  local items, cur = {}, nil
  for _, line in ipairs(vim.split(out .. "\n", "\n")) do
    local path = line:match("^worktree (.+)")
    if path then
      cur = { path = path, branch = "(detached)" }
    elseif line:match("^branch ") then
      cur.branch = line:gsub("^branch refs/heads/", "")
    elseif line == "bare" and cur then
      cur.branch = "(bare)"
    elseif line == "" and cur then
      table.insert(items, cur)
      cur = nil
    end
  end
  return items
end

local function current_root()
  local ok, root = git({ "rev-parse", "--show-toplevel" })
  return ok and root or nil
end

local function find(query)
  for _, wt in ipairs(M.list()) do
    if wt.branch == query or wt.path == query or vim.fs.basename(wt.path) == query then
      return wt
    end
  end
end

local function is_under(path, root)
  return path == root or vim.startswith(path, root .. "/")
end

local function claude_running()
  local ok, term = pcall(require, "claudecode.terminal")
  return ok and term.get_active_terminal_bufnr() ~= nil
end

-- Rewrites the claudecode lockfile so external `claude` sessions see the new workspace
local function refresh_claude_lockfile()
  local ok, claudecode = pcall(require, "claudecode")
  if ok and claudecode.state and claudecode.state.port then
    require("claudecode.lockfile").create(claudecode.state.port, claudecode.state.auth_token)
  end
end

local function pick(prompt, cb, filter)
  local root = current_root()
  local items = vim.tbl_filter(filter or function()
    return true
  end, M.list())
  if #items == 0 then
    return notify("No worktrees found", vim.log.levels.WARN)
  end
  vim.ui.select(items, {
    prompt = prompt,
    format_item = function(wt)
      local mark = wt.path == root and "* " or "  "
      return string.format("%s%-35s %s", mark, wt.branch, vim.fn.fnamemodify(wt.path, ":~"))
    end,
  }, function(wt)
    if wt then
      cb(wt)
    end
  end)
end

---Switch Neovim (and Claude, if running) to another worktree
---@param path string
---@param opts? {claude?: boolean} force opening Claude after switching
function M.switch(path, opts)
  opts = opts or {}
  local old_root = current_root()
  local restart_claude = opts.claude or claude_running()

  if old_root == path then
    if opts.claude and not claude_running() then
      vim.cmd("ClaudeCode")
    end
    return notify("Already in " .. vim.fn.fnamemodify(path, ":~"))
  end

  -- File to reopen on the other side
  local rel
  local cur = vim.api.nvim_buf_get_name(0)
  if old_root and cur ~= "" and is_under(cur, old_root) then
    rel = cur:sub(#old_root + 2)
  end

  -- Wiping the terminal buffer kills the Claude process so it can be respawned in the new cwd
  local claude_buf = claude_running() and require("claudecode.terminal").get_active_terminal_bufnr()
  if claude_buf then
    -- Drop the TermClose handler so the kill isn't reported as a crash
    for _, au in ipairs(vim.api.nvim_get_autocmds({ event = "TermClose", buffer = claude_buf })) do
      vim.api.nvim_del_autocmd(au.id)
    end
    vim.api.nvim_buf_delete(claude_buf, { force = true })
  end

  vim.cmd.cd(vim.fn.fnameescape(path))

  if rel and vim.uv.fs_stat(path .. "/" .. rel) then
    vim.cmd.edit(vim.fn.fnameescape(path .. "/" .. rel))
  end

  if old_root then
    local kept = 0
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(buf)
      if vim.bo[buf].buflisted and name ~= "" and is_under(name, old_root) then
        if vim.bo[buf].modified then
          kept = kept + 1
        else
          Snacks.bufdelete.delete({ buf = buf, force = true })
        end
      end
    end
    if kept > 0 then
      notify(kept .. " modified buffer(s) from the previous worktree were kept open", vim.log.levels.WARN)
    end

    -- Stop LSP servers rooted in the old worktree
    for _, client in ipairs(vim.lsp.get_clients()) do
      if client.root_dir and is_under(client.root_dir, old_root) then
        client:stop()
      end
    end
  end

  refresh_claude_lockfile()
  if restart_claude then
    vim.cmd("ClaudeCode")
  end

  local _, branch = git({ "branch", "--show-current" }, path)
  notify("Switched to " .. (branch ~= "" and branch or vim.fn.fnamemodify(path, ":~")))
end

function M.pick_switch(opts)
  local root = current_root()
  local with_claude = opts and opts.claude
  pick("Switch worktree", function(wt)
    M.switch(wt.path, opts)
  end, function(wt)
    -- With Claude, the current worktree stays selectable to just open Claude there
    return with_claude or wt.path ~= root
  end)
end

---@param branch string
---@param base? string
---@param opts? {claude?: boolean}
function M.add(branch, base, opts)
  local existing = find(branch)
  if existing then
    return M.switch(existing.path, opts)
  end

  local list = M.list()
  if #list == 0 then
    return notify("Not in a git repository", vim.log.levels.ERROR)
  end
  local main = list[1].path
  local dir = string.format("%s/%s.worktrees/%s", vim.fs.dirname(main), vim.fs.basename(main), branch:gsub("/", "-"))

  local args
  if git({ "show-ref", "--verify", "--quiet", "refs/heads/" .. branch }) then
    args = { "worktree", "add", dir, branch }
  elseif git({ "show-ref", "--verify", "--quiet", "refs/remotes/origin/" .. branch }) then
    args = { "worktree", "add", "--track", "-b", branch, dir, "origin/" .. branch }
  else
    args = { "worktree", "add", "-b", branch, dir }
    if base and base ~= "" then
      table.insert(args, base)
    end
  end

  local ok, _, err = git(args, main)
  if not ok then
    return notify(err, vim.log.levels.ERROR)
  end

  -- Copy untracked env files from the main worktree
  for name, type in vim.fs.dir(main) do
    if type == "file" and name:match("^%.env") and not git({ "ls-files", "--error-unmatch", name }, main) then
      vim.uv.fs_copyfile(main .. "/" .. name, dir .. "/" .. name)
    end
  end

  notify("Created worktree " .. vim.fn.fnamemodify(dir, ":~"))
  M.switch(dir, opts)
end

function M.prompt_add(opts)
  vim.ui.input({ prompt = "New worktree branch: " }, function(branch)
    if not branch or branch == "" then
      return
    end
    local is_new = not git({ "show-ref", "--verify", "--quiet", "refs/heads/" .. branch })
      and not git({ "show-ref", "--verify", "--quiet", "refs/remotes/origin/" .. branch })
    if not is_new then
      return M.add(branch, nil, opts)
    end
    local _, head = git({ "branch", "--show-current" })
    vim.ui.input({ prompt = "Base branch: ", default = head }, function(base)
      if base then
        M.add(branch, base, opts)
      end
    end)
  end)
end

---@param wt {path: string, branch: string}
function M.remove(wt)
  local main = M.list()[1].path
  if wt.path == main then
    return notify("Refusing to remove the main worktree", vim.log.levels.ERROR)
  end

  local function do_remove(force, delete_branch)
    if is_under(vim.fn.getcwd(), wt.path) then
      M.switch(main)
    end
    local args = { "worktree", "remove", wt.path }
    if force then
      table.insert(args, "--force")
    end
    local ok, _, err = git(args, main)
    if not ok then
      return notify(err, vim.log.levels.ERROR)
    end
    if delete_branch and wt.branch:sub(1, 1) ~= "(" then
      local bok, _, berr = git({ "branch", force and "-D" or "-d", wt.branch }, main)
      if not bok then
        notify(berr, vim.log.levels.WARN)
      end
    end
    notify("Removed " .. wt.branch)
  end

  local _, status = git({ "status", "--porcelain" }, wt.path)
  local dirty = status ~= ""
  local choices = dirty and { "Force remove (discard changes)", "Force remove + delete branch", "Cancel" }
    or { "Remove", "Remove + delete branch", "Cancel" }

  vim.ui.select(choices, {
    prompt = string.format("Remove %s?%s", wt.branch, dirty and " (has uncommitted changes)" or ""),
  }, function(_, idx)
    if idx == 1 or idx == 2 then
      do_remove(dirty, idx == 2)
    end
  end)
end

function M.pick_remove()
  local main = M.list()[1]
  pick("Remove worktree", M.remove, function(wt)
    return main and wt.path ~= main.path
  end)
end

local function complete_worktrees()
  return vim.tbl_map(function(wt)
    return wt.branch
  end, M.list())
end

local function complete_branches()
  local _, out = git({ "branch", "-a", "--format=%(refname:short)" })
  local seen, res = {}, {}
  for _, b in ipairs(vim.split(out, "\n")) do
    b = b:gsub("^origin/", "")
    if b ~= "" and b ~= "origin" and not seen[b] then
      seen[b] = true
      table.insert(res, b)
    end
  end
  return res
end

local function by_name(name, opts)
  local wt = find(name)
  if not wt then
    return notify("No worktree for '" .. name .. "'", vim.log.levels.ERROR)
  end
  M.switch(wt.path, opts)
end

function M.setup()
  local cmd = vim.api.nvim_create_user_command

  cmd("Worktree", function(o)
    if o.args == "" then
      M.pick_switch()
    else
      by_name(o.args)
    end
  end, { nargs = "?", complete = complete_worktrees, desc = "Switch worktree" })

  cmd("WorktreeClaude", function(o)
    if o.args == "" then
      M.pick_switch({ claude = true })
    else
      by_name(o.args, { claude = true })
    end
  end, { nargs = "?", complete = complete_worktrees, desc = "Switch worktree and open Claude" })

  cmd("WorktreeAdd", function(o)
    if o.fargs[1] then
      M.add(o.fargs[1], o.fargs[2], { claude = o.bang })
    else
      M.prompt_add({ claude = o.bang })
    end
  end, { nargs = "*", bang = true, complete = complete_branches, desc = "Create worktree (! opens Claude)" })

  cmd("WorktreeRemove", function(o)
    if o.args == "" then
      return M.pick_remove()
    end
    local wt = find(o.args)
    if not wt then
      return notify("No worktree for '" .. o.args .. "'", vim.log.levels.ERROR)
    end
    M.remove(wt)
  end, { nargs = "?", complete = complete_worktrees, desc = "Remove worktree" })

  local map = vim.keymap.set
  map("n", "<leader>gww", M.pick_switch, { desc = "Switch Worktree" })
  map("n", "<leader>gwa", M.prompt_add, { desc = "Add Worktree" })
  map("n", "<leader>gwc", function()
    M.pick_switch({ claude = true })
  end, { desc = "Worktree + Claude" })
  map("n", "<leader>gwC", function()
    M.prompt_add({ claude = true })
  end, { desc = "Add Worktree + Claude" })
  map("n", "<leader>gwd", M.pick_remove, { desc = "Remove Worktree" })

  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add({ { "<leader>gw", group = "worktrees" } })
  end
end

return M
