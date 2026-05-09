local M = {}

M.buf_id = nil
M.win_id = nil
M.job_id = nil
M.is_maximized = false

local function find_application_id()
  local files = { 'build.gradle.kts', 'app/build.gradle.kts', 'build.gradle', 'app/build.gradle' }
  for _, f in ipairs(files) do
    if vim.fn.filereadable(f) == 1 then
      local lines = vim.fn.readfile(f)
      for _, line in ipairs(lines) do
        local id = line:match('applicationId%s*=%s*"([^"]+)"') or line:match('applicationId%s*"([^"]+)"')
        if id then return id end
      end
    end
  end
  return nil
end

local function setup_buffer_keymaps(bufnr)
  vim.keymap.set('n', 'q', function() M.toggle() end, { buffer = bufnr, desc = 'Hide Logcat' })
  vim.keymap.set('n', 'M', function() M.maximize() end, { buffer = bufnr, desc = 'Maximize/Restore Logcat' })
  vim.keymap.set('n', 'C', function() 
    vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
  end, { buffer = bufnr, desc = 'Clear Logcat Buffer' })
end

function M.setup_syntax()
  if not M.buf_id or not vim.api.nvim_buf_is_valid(M.buf_id) then return end
  vim.api.nvim_buf_call(M.buf_id, function()
    vim.cmd([[
      syntax clear
      syntax match LogcatError   /^E\/.*/
      syntax match LogcatWarning /^W\/.*/
      syntax match LogcatInfo    /^I\/.*/
      syntax match LogcatDebug   /^D\/.*/
      syntax match LogcatVerbose /^V\/.*/
      
      highlight link LogcatError   DiagnosticError
      highlight link LogcatWarning DiagnosticWarn
      highlight link LogcatInfo    DiagnosticInfo
      highlight link LogcatDebug   DiagnosticHint
      highlight link LogcatVerbose Comment
    ]])
  end)
end

function M.open()
  if M.win_id and vim.api.nvim_win_is_valid(M.win_id) then
    vim.api.nvim_set_current_win(M.win_id)
    return
  end

  local height = math.floor(vim.o.lines * 0.25)
  vim.cmd("botright " .. height .. "split")
  M.win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.win_id, M.buf_id)
  
  -- Window local options
  vim.api.nvim_set_option_value("number", false, { win = M.win_id })
  vim.api.nvim_set_option_value("relativenumber", false, { win = M.win_id })
  vim.api.nvim_set_option_value("winfixheight", true, { win = M.win_id })
  vim.api.nvim_set_option_value("wrap", false, { win = M.win_id })
end

function M.start()
  if M.job_id then
    M.open()
    return
  end

  -- Create buffer if it doesn't exist
  if not M.buf_id or not vim.api.nvim_buf_is_valid(M.buf_id) then
    M.buf_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(M.buf_id, "Android Logcat")
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = M.buf_id })
    vim.api.nvim_set_option_value("swapfile", false, { buf = M.buf_id })
    vim.api.nvim_set_option_value("bufhidden", "hide", { buf = M.buf_id })
    vim.api.nvim_set_option_value("modifiable", false, { buf = M.buf_id })
    M.setup_syntax()
    setup_buffer_keymaps(M.buf_id)
  end

  M.open()

  local cmd = { "adb", "logcat", "-v", "brief" }
  local package_id = find_application_id()
  
  if package_id then
    local handle = io.popen("adb shell pidof " .. package_id)
    local pid = handle:read("*a"):gsub("%s+", "")
    handle:close()
    if pid ~= "" then
      table.insert(cmd, "--pid=" .. pid)
      vim.notify("Streaming Logcat for " .. package_id .. " (PID: " .. pid .. ")", vim.log.levels.INFO)
    else
      vim.notify("App " .. package_id .. " not running. Showing full logcat.", vim.log.levels.WARN)
    end
  end

  M.job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data then
        vim.schedule(function()
          if not M.buf_id or not vim.api.nvim_buf_is_valid(M.buf_id) then return end
          
          -- Remove empty entries that jobstart might send
          local clean_data = {}
          for _, line in ipairs(data) do
            if line ~= "" then
              table.insert(clean_data, line:gsub("\r", ""))
            end
          end
          
          if #clean_data == 0 then return end

          vim.api.nvim_set_option_value("modifiable", true, { buf = M.buf_id })
          vim.api.nvim_buf_set_lines(M.buf_id, -1, -1, false, clean_data)
          vim.api.nvim_set_option_value("modifiable", false, { buf = M.buf_id })
          
          -- Auto-scroll if cursor is in the logcat window
          if M.win_id and vim.api.nvim_win_is_valid(M.win_id) then
            local line_count = vim.api.nvim_buf_line_count(M.buf_id)
            -- Only auto-scroll if we were already near the bottom
            local cursor = vim.api.nvim_win_get_cursor(M.win_id)
            if cursor[1] >= line_count - #clean_data - 2 then
              vim.api.nvim_win_set_cursor(M.win_id, { line_count, 0 })
            end
          end
        end)
      end
    end,
    on_exit = function()
      M.job_id = nil
    end
  })
end

function M.toggle()
  if M.win_id and vim.api.nvim_win_is_valid(M.win_id) then
    vim.api.nvim_win_hide(M.win_id)
    M.win_id = nil
  else
    if not M.job_id then
      M.start()
    else
      M.open()
    end
  end
end

function M.maximize()
  if not M.win_id or not vim.api.nvim_win_is_valid(M.win_id) then return end
  
  if M.is_maximized then
    local height = math.floor(vim.o.lines * 0.25)
    vim.api.nvim_win_set_height(M.win_id, height)
    M.is_maximized = false
  else
    vim.api.nvim_win_set_height(M.win_id, vim.o.lines)
    M.is_maximized = true
  end
end

function M.stop()
  if M.job_id then
    vim.fn.jobstop(M.job_id)
    M.job_id = nil
  end
  if M.win_id and vim.api.nvim_win_is_valid(M.win_id) then
    vim.api.nvim_win_close(M.win_id, true)
    M.win_id = nil
  end
  if M.buf_id and vim.api.nvim_buf_is_valid(M.buf_id) then
    vim.api.nvim_buf_delete(M.buf_id, { force = true })
    M.buf_id = nil
  end
  vim.notify("Logcat stopped.", vim.log.levels.INFO)
end

return M
