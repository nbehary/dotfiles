-- DAP (Debug Adapter Protocol) Configuration

local ok_dap, dap = pcall(require, 'dap')
if not ok_dap then
  return
end

local ok_ui, dapui = pcall(require, 'dapui')
if not ok_ui then
  return
end

dap.set_log_level 'DEBUG' -- view with :DapShowLog

-- UI setup
dapui.setup {
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- kotlin-debug-adapter speaks DAP and translates to JDWP.
-- Used for both Kotlin and Java since Android apps run on a JVM regardless of source language.
dap.adapters.kotlin = {
  type = 'executable',
  command = vim.fn.stdpath 'data' .. '/mason/bin/kotlin-debug-adapter',
}

local android_attach_config = {
  type = 'kotlin',
  request = 'attach',
  name = 'Attach to Android (adb forward, port 5005)',
  hostName = 'localhost',
  port = 5005,
  timeout = 10000,
  projectRoot = '${workspaceFolder}',
}

dap.configurations.kotlin = { android_attach_config }
dap.configurations.java = { android_attach_config }

-- AndroidDebug: build, install, launch, forward JDWP via shell script, then attach.
vim.api.nvim_create_user_command('AndroidDebug', function()
  local script = vim.fn.expand '~/dotfiles/bin/android-debug-launch'
  if vim.fn.executable(script) ~= 1 then
    vim.notify('android-debug-launch not found or not executable: ' .. script, vim.log.levels.ERROR)
    return
  end

  local root = vim.fs.dirname(vim.fs.find({ 'gradlew', 'settings.gradle', 'settings.gradle.kts' }, { upward = true })[1])
  if not root then
    vim.notify('AndroidDebug: could not find project root (no gradlew found)', vim.log.levels.ERROR)
    return
  end

  vim.notify('Building and launching Android app...', vim.log.levels.INFO)

  vim.system({ script }, { cwd = root, text = true }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 then
        vim.notify('android-debug-launch failed:\n' .. (obj.stderr or '') .. (obj.stdout or ''), vim.log.levels.ERROR)
        return
      end
      vim.notify('App launched. Attaching debugger...', vim.log.levels.INFO)
      dap.run {
        type = 'kotlin',
        request = 'attach',
        name = 'Android Debug',
        hostName = 'localhost',
        port = 5005,
        timeout = 10000,
        projectRoot = root,
      }
    end)
  end)
end, { desc = 'Build, install, and debug current Android project' })

-- AndroidRun: build and install without attaching a debugger.
vim.api.nvim_create_user_command('AndroidRun', function()
  local script = vim.fn.expand '~/dotfiles/bin/android-run'
  if vim.fn.executable(script) ~= 1 then
    vim.notify('android-run not found or not executable: ' .. script, vim.log.levels.ERROR)
    return
  end

  local root = vim.fs.dirname(vim.fs.find({ 'gradlew', 'settings.gradle', 'settings.gradle.kts' }, { upward = true })[1])
  if not root then
    vim.notify('AndroidRun: could not find project root (no gradlew found)', vim.log.levels.ERROR)
    return
  end

  vim.notify('Building and launching Android app...', vim.log.levels.INFO)

  vim.system({ script }, { cwd = root, text = true }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 then
        vim.notify('android-run failed:\n' .. (obj.stderr or '') .. (obj.stdout or ''), vim.log.levels.ERROR)
      else
        vim.notify('App launched.', vim.log.levels.INFO)
      end
    end)
  end)
end, { desc = 'Build, install, and run Android app (no debugger)' })

-- Keymaps
vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: Toggle UI' })
vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function()
  dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = 'Debug: Set Conditional Breakpoint' })
vim.keymap.set('n', '<leader>da', '<cmd>AndroidDebug<CR>', { desc = 'Android Debug' })
vim.keymap.set('n', '<leader>dr', '<cmd>AndroidRun<CR>', { desc = 'Android Run (no debugger)' })
