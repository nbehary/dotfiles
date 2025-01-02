local state = {
  floating = {
    buf = -1,
    win = -1,
  }

}

function create_floating_window(opts)
  opts = opts or {} -- Initialize opts if not provided

  -- Calculate default width and height as 80% of the screen
  local ui = vim.api.nvim_list_uis()[1] -- Get the current UI
  local default_width = math.floor(ui.width * 0.8)
  local default_height = math.floor(ui.height * 0.8)

  -- Use provided width and height or defaults
  local width = opts.width or default_width
  local height = opts.height or default_height

  -- Calculate centered position
  local col = math.floor((ui.width - width) / 2)
  local row = math.floor((ui.height - height) / 2)

  -- Create the floating window
  local buf = vim.api.nvim_create_buf(false, true) -- Unlisted, scratch buffer
  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    anchor = 'NW',
    style = 'minimal',
    border = 'rounded',
  }
  local win = vim.api.nvim_open_win(buf, true, win_opts)

  return { buf = buf,win = win}
end

--vim.keymap.set('n', '<leader>t', function()
vim.api.nvim_create_user_command("Floatterminal", function()
    if not vim.nvim_win_is_valid(state.floating.win) then
      state.floating = create_floating_window()
    else
      vim.api.nvim_win_hide(state.floating.win)
    end
end,{})

--    if not vim.nvim_win_is_valid(state.floating.win) then
--      state.floating = create_floating_window()
--    else
--      vim.api.nvim_win_hide(state.floating.win)
--    end
