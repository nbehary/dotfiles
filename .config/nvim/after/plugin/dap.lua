-- DAP (Debug Adapter Protocol) Configuration

local ok_dap, dap = pcall(require, 'dap')
if not ok_dap then
  return
end

local ok_ui, dapui = pcall(require, 'dapui')
if not ok_ui then
  return
end

-- Enable debug logging; view with :DapShowLog
dap.set_log_level 'DEBUG'

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

-- Auto-open/close UI with debug session
dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- Android: attach to a running app via adb-forwarded JDWP port.
dap.configurations.java = dap.configurations.java or {}
table.insert(dap.configurations.java, {
  type = 'java',
  request = 'attach',
  name = 'Android: Attach (adb forward tcp:5005)',
  hostName = 'localhost',
  port = 5005,
})

-- kotlin-debug-adapter: standalone adapter, no LSP required
dap.adapters.kotlin = {
  type = 'executable',
  command = vim.fn.stdpath 'data' .. '/mason/bin/kotlin-debug-adapter',
}

dap.configurations.kotlin = dap.configurations.kotlin or {}
table.insert(dap.configurations.kotlin, {
  type = 'kotlin',
  request = 'attach',
  name = 'Android: Attach (adb forward tcp:5005)',
  hostName = 'localhost',
  port = 5005,
  timeout = 30000,
})

-- Detect the Android applicationId from build.gradle / build.gradle.kts / AndroidManifest.xml
local function detect_app_id(root)
  local function read_file(path)
    local f = io.open(path, 'r')
    if not f then return nil end
    local content = f:read '*a'
    f:close()
    return content
  end

  for _, rel in ipairs { 'app/build.gradle.kts', 'app/build.gradle' } do
    local content = read_file(root .. '/' .. rel)
    if content then
      local id = content:match 'applicationId%s*=?%s*["\']([%w%.]+)["\']'
      if id then return id end
    end
  end

  local manifest = read_file(root .. '/app/src/main/AndroidManifest.xml')
  if manifest then
    return manifest:match '<manifest[^>]+package="([%w%.]+)"'
  end
end

-- Detect the LAUNCHER activity via adb (requires the app to be installed)
local function resolve_activity(app_id, callback)
  vim.system({ 'adb', 'shell', 'cmd', 'package', 'resolve-activity', '--brief', '-c', 'android.intent.category.LAUNCHER', app_id }, {}, function(result)
    local component = result.stdout and result.stdout:match '([%w%.]+/[%w%.]+)%s*$'
    vim.schedule(function() callback(component) end)
  end)
end

-- Wait until tcp host:port actually accepts connections (polls every 300ms up to timeout_ms).
local function wait_for_port(host, port, timeout_ms, callback)
  local start = vim.uv.now()
  local function try()
    local client = vim.uv.new_tcp()
    client:connect(host, port, function(err)
      client:close()
      if not err then
        vim.schedule(function() callback(true) end)
      elseif vim.uv.now() - start < timeout_ms then
        vim.defer_fn(try, 300)
      else
        vim.schedule(function() callback(false) end)
      end
    end)
  end
  try()
end


local function wait_for_pid(app_id, interval_ms, max_attempts, callback)
  local attempts = 0
  local function poll()
    attempts = attempts + 1
    vim.system({ 'adb', 'shell', 'pidof', app_id }, {}, function(result)
      local pid = result.stdout and result.stdout:match '%d+'
      if pid then
        vim.schedule(function() callback(pid) end)
      elseif attempts < max_attempts then
        vim.defer_fn(poll, interval_ms)
      else
        vim.schedule(function() callback(nil) end)
      end
    end)
  end
  vim.defer_fn(poll, interval_ms)
end

-- <leader>da: Launch app in debug-wait mode, forward JDWP port, then attach DAP.
-- Detects applicationId and launcher activity automatically; prompts as fallback.
local function android_launch_and_attach()
  if vim.fn.executable 'adb' == 0 then
    vim.notify('adb not found in PATH', vim.log.levels.ERROR)
    return
  end

  local root = vim.fs.dirname(vim.fs.find({ 'gradlew', 'settings.gradle', 'settings.gradle.kts' }, { upward = true })[1])
  if not root then
    vim.notify('Android project root not found', vim.log.levels.ERROR)
    return
  end

  -- Prefer KDA (standalone, opens DAP UI immediately, supports JDWP attach).
  -- Fall back to jdtls only if KDA is not installed.
  local kda = vim.fn.stdpath 'data' .. '/mason/bin/kotlin-debug-adapter'
  local run_config
  if vim.fn.executable(kda) == 1 then
    -- KDA requires projectRoot; use the project root (it's the Gradle root).
    -- Class-file discovery within the project is lazy and won't block the attach.
    run_config = {
      type = 'kotlin',
      request = 'attach',
      name = 'Android Debug (KDA)',
      hostName = '127.0.0.1', -- explicit IPv4; 'localhost' can resolve to ::1 on macOS
      port = 5005,
      timeout = 30000,
      projectRoot = root,
    }
  else
    local jdtls_clients = vim.lsp.get_clients { name = 'jdtls' }
    if #jdtls_clients == 0 then
      vim.notify('Android debug: run :MasonToolsInstall to install kotlin-debug-adapter, or open a Java file to start jdtls.', vim.log.levels.ERROR)
      return
    end
    if not dap.adapters.java then
      require('jdtls').setup_dap { hotcodereplace = 'auto' }
    end
    run_config = {
      type = 'java',
      request = 'attach',
      name = 'Android Debug (jdtls)',
      hostName = 'localhost',
      port = 5005,
      cwd = root,
    }
  end

  local app_id = detect_app_id(root)
  if not app_id or app_id == '' then
    app_id = vim.fn.input 'Android package name: '
    if app_id == '' then return end
  end

  resolve_activity(app_id, function(component)
    if not component or component == '' then
      vim.notify('Could not resolve launcher activity — enter manually', vim.log.levels.WARN)
      component = vim.fn.input('Activity (e.g. com.pkg/.MainActivity): ')
      if component == '' then return end
    end

    -- Step 1: force-stop any existing process so we always get a fresh debug-wait instance
    vim.system({ 'adb', 'shell', 'am', 'force-stop', app_id }, {}, function(_)
      -- Step 2: launch in debug-wait mode
      vim.schedule(function()
        vim.notify('Starting ' .. app_id .. ' (debug-wait)…', vim.log.levels.INFO)
      end)
      vim.system({ 'adb', 'shell', 'am', 'start', '-D', '-n', component }, {}, function(launch)
        if launch.code ~= 0 then
          vim.schedule(function()
            vim.notify('am start failed: ' .. (launch.stderr or ''), vim.log.levels.ERROR)
          end)
          return
        end

        -- Step 3: wait for PID (fresh process after force-stop)
        wait_for_pid(app_id, 500, 20, function(pid)
          if not pid then
            vim.notify('Timed out waiting for ' .. app_id .. ' to start', vim.log.levels.ERROR)
            return
          end

          -- Step 4: clean up stale forward, then set new one
          vim.system({ 'adb', 'forward', '--remove', 'tcp:5005' }, {}, function(_)
            vim.system({ 'adb', 'forward', 'tcp:5005', 'jdwp:' .. pid }, {}, function(fwd)
              vim.schedule(function()
                if fwd.code ~= 0 then
                  vim.notify('adb forward failed: ' .. (fwd.stderr or ''), vim.log.levels.ERROR)
                  return
                end
                vim.notify('Forwarded tcp:5005 → jdwp:' .. pid .. '  (' .. app_id .. ')', vim.log.levels.INFO)
                -- Step 5: wait until the JDWP socket is actually accepting connections
                wait_for_port('127.0.0.1', 5005, 15000, function(ready)
                  if not ready then
                    vim.notify('JDWP port 5005 not ready after 15s', vim.log.levels.ERROR)
                    return
                  end
                  dap.run(run_config)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

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
vim.keymap.set('n', '<leader>da', android_launch_and_attach, { desc = 'Debug: Android Launch & Attach' })

