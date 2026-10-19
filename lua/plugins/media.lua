-- Audio and video playback through mpv.
-- Neovim can't play media, so opening one of these files (from the explorer, picker or `:e`)
-- hands it to mpv instead of loading the binary into a buffer.
local audio = { "mp3", "wav", "flac", "ogg", "opus", "m4a", "aac" }
local video = { "mp4", "mov", "avi", "mkv", "webm" }

local function is_audio(file)
  return vim.tbl_contains(audio, vim.fn.fnamemodify(file, ":e"):lower())
end

local function play(file)
  if vim.fn.executable("mpv") == 0 then
    vim.notify("mpv not found", vim.log.levels.ERROR)
    return
  end
  if is_audio(file) then
    -- Floating terminal so mpv's keys work (space pauses, q quits); closes when playback ends
    Snacks.terminal({ "mpv", "--no-video", "--term-osd-bar", file }, {
      win = { position = "float", width = 0.6, height = 0.2, border = "rounded", title = " " .. vim.fn.fnamemodify(file, ":t") .. " " },
    })
  else
    -- Video gets its own mpv window: full resolution, and kitty graphics from mpv don't survive tmux
    -- osd-level=3 keeps elapsed/total time on screen
    vim.system({ "mpv", "--osd-level=3", file }, { detach = true })
  end
end

local function pick_media()
  Snacks.picker.files({
    title = "Media",
    cwd = LazyVim.root(),
    ft = vim.list_extend(vim.deepcopy(audio), video),
    -- Generated media usually lives in gitignored dirs (e.g. storage/)
    ignored = true,
    confirm = function(picker, item)
      picker:close()
      play(Snacks.picker.util.path(item))
    end,
  })
end

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = vim.api.nvim_create_augroup("media_play", { clear = true }),
  pattern = "*." .. table.concat(vim.list_extend(vim.deepcopy(audio), video), ",*."),
  callback = function(e)
    play(e.file)
    -- Videos keep the buffer, where snacks.image shows the first frame; audio has nothing to show
    if is_audio(e.file) then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(e.buf) then
          Snacks.bufdelete({ buf = e.buf, force = true })
        end
      end)
    end
  end,
})

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>mo", pick_media, desc = "Media: pick and play (mpv)" },
    },
  },
}
