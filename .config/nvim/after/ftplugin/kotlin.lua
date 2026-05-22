-- Auto-fold import block on file open
local function fold_imports()
  local first, last
  for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:match '^import ' then
      first = first or i
      last = i
    end
  end
  if first and last and last > first then
    vim.opt_local.foldmethod = 'manual'
    vim.cmd(first .. ',' .. last .. 'fold')
  end
end

vim.schedule(fold_imports)

-- Kotlin-specific settings for Android development
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true

-- Gradle build/run keymaps (only set when in a Gradle project)
local _root = vim.fs.find({ 'gradlew' }, { upward = true })
local root_dir = nil
if _root and _root[1] then
  root_dir = vim.fs.dirname(_root[1])
end
if root_dir then
  local gradlew = root_dir .. '/gradlew'
  local project_config = require 'android.project_config'
  local task_discovery = require 'android.task_discovery'

  -- Read the app package id from build.gradle.kts / build.gradle, falling back to the manifest
  local function get_package()
    local pkg = nil
    for _, name in ipairs { '/app/build.gradle.kts', '/app/build.gradle' } do
      local f = root_dir .. name
      if vim.fn.filereadable(f) == 1 then
        for _, line in ipairs(vim.fn.readfile(f)) do
          pkg = line:match "namespace[%s=:]*['\"]([^'\"]+)['\"]"
          if pkg then break end
          pkg = line:match "applicationId[%s=:]*['\"]([^'\"]+)['\"]"
          if pkg then break end
        end
      end
      if pkg then break end
    end
    if not pkg then
      local manifest = root_dir .. '/app/src/main/AndroidManifest.xml'
      if vim.fn.filereadable(manifest) == 1 then
        for _, line in ipairs(vim.fn.readfile(manifest)) do
          pkg = line:match 'package="([^"]+)"'
          if pkg then break end
        end
      end
    end
    return pkg
  end

  -- On first Kotlin file in project, discover install tasks if not already configured
  local init_key = 'android_project_' .. root_dir
  if not vim.g[init_key] then
    vim.g[init_key] = true
    vim.schedule(function()
      if not project_config.get_install_task(root_dir) then
        local tasks = task_discovery.discover_install_tasks(root_dir)
        if #tasks > 0 then
          task_discovery.select_install_task(tasks, function(choice)
            if choice then
              project_config.set_install_task(root_dir, choice)
              vim.notify('Saved install task: ' .. choice)
            end
          end)
        end
      end
    end)
  end

  vim.keymap.set('n', '<leader>gb', function()
    vim.cmd('!' .. gradlew .. ' assembleDebug')
  end, { buffer = 0, desc = '[G]radle [B]uild (assembleDebug)' })

  vim.keymap.set('n', '<leader>gt', function()
    vim.cmd('!' .. gradlew .. ' test')
  end, { buffer = 0, desc = '[G]radle [T]est' })

  vim.keymap.set('n', '<leader>gc', function()
    vim.cmd('!' .. gradlew .. ' clean')
  end, { buffer = 0, desc = '[G]radle [C]lean' })

  vim.keymap.set('n', '<leader>gl', function()
    local pkg = get_package()
    vim.cmd 'botright 20split'
    if pkg then
      vim.cmd('terminal adb logcat --pid=$(adb shell pidof -s ' .. vim.fn.shellescape(pkg) .. ')')
    else
      vim.cmd 'terminal adb logcat'
    end
    vim.cmd 'startinsert'
  end, { buffer = 0, desc = '[G]radle [L]ogcat (filtered to app)' })

  -- Logcat showing only crashes/errors for the app (survives app restarts)
  vim.keymap.set('n', '<leader>gE', function()
    local pkg = get_package()
    vim.cmd 'botright 20split'
    if pkg then
      vim.cmd('terminal adb logcat *:E | grep --line-buffered -E ' .. vim.fn.shellescape(pkg .. '|FATAL|AndroidRuntime'))
    else
      vim.cmd 'terminal adb logcat *:E'
    end
    vim.cmd 'startinsert'
  end, { buffer = 0, desc = '[G]radle [E]rrors logcat (app crashes)' })

  -- android CLI integration
  if vim.fn.executable 'android' == 1 then
    -- Helper to get the first active connected device/emulator
    local function get_active_device()
      local devices = {}
      local lines = vim.fn.systemlist 'adb devices 2>/dev/null'
      for _, line in ipairs(lines) do
        local serial, state = line:match '^([%w%.%-%:]+)%s+(device)$'
        if serial and state then
          table.insert(devices, serial)
        end
      end
      return devices[1]
    end

    -- Find the debug APK: check configured variant, then optionally firebaseCt, then any debug APK
    local function find_debug_apk()
      local config = project_config.load_config(root_dir) or {}

      -- Try user-configured variant first
      if config.apk_variant then
        local path = root_dir .. '/app/build/outputs/apk/' .. config.apk_variant .. '/debug/*.apk'
        local found = vim.fn.glob(path, false, true)
        if #found > 0 then return found[1] end
      end

      -- Try firebaseCt variant ONLY if package name starts with com.cccis
      local pkg = get_package()
      if pkg and pkg:match '^com%.cccis' then
        local firebase_path = root_dir .. '/app/build/outputs/apk/firebaseCt/debug/*.apk'
        local found = vim.fn.glob(firebase_path, false, true)
        if #found > 0 then return found[1] end
      end

      -- Fall back to any debug APK
      local generic_path = root_dir .. '/app/build/outputs/apk/*/debug/*.apk'
      local found = vim.fn.glob(generic_path, false, true)
      if #found > 0 then return found[1] end

      return nil
    end

    local function run_app()
      local pkg = get_package()
      local is_cccis = pkg and pkg:match '^com%.cccis'
      local task = is_cccis and 'installFirebaseCtDebug' or 'installDebug'
      
      -- Evaluate APK dynamically
      local apk = find_debug_apk()
      if not apk then
        -- Variant-specific fallback path
        apk = is_cccis and (root_dir .. '/app/build/outputs/apk/firebaseCt/debug/app-firebaseCt-debug.apk')
                       or (root_dir .. '/app/build/outputs/apk/debug/app-debug.apk')
      end

      local device = get_active_device()
      local run_flags = device and (' --device ' .. vim.fn.shellescape(device)) or ''

      vim.cmd('!' .. gradlew .. ' ' .. task .. ' && android run' .. run_flags .. ' --apks ' .. vim.fn.shellescape(apk))
    end

    -- Build with appropriate task (firebaseCt vs standard), then deploy and launch on connected device
    vim.keymap.set('n', '<leader>gr', run_app, { buffer = 0, desc = '[G]radle [R]un on device (build + deploy)' })
    vim.keymap.set('n', '<F9>', run_app, { buffer = 0, desc = 'Build and Run App' })

    -- Deploy existing APK without rebuilding
    vim.keymap.set('n', '<leader>gR', function()
      local apk = find_debug_apk()
      if not apk then
        vim.notify('No debug APK found — build first with <leader>gb', vim.log.levels.WARN)
        return
      end
      
      local device = get_active_device()
      local run_flags = device and (' --device ' .. vim.fn.shellescape(device)) or ''

      vim.cmd('!android run' .. run_flags .. ' --apks ' .. vim.fn.shellescape(apk))
    end, { buffer = 0, desc = '[G]radle [R]edeploy (no build)' })

    -- Build and deploy in debug mode with auto port-forward and DAP attach
    vim.keymap.set('n', '<C-F9>', function()
      local pkg = get_package()
      if not pkg then
        vim.notify('Could not determine app package', vim.log.levels.ERROR)
        return
      end

      local is_cccis = pkg:match '^com%.cccis'
      local task = is_cccis and 'assembleFirebaseCtDebug' or 'assembleDebug'

      -- Terminate any existing active DAP session to ensure clean re-attaching
      local ok_dap, dap = pcall(require, 'dap')
      if ok_dap and dap.session() then
        dap.terminate()
      end

      -- Guard against concurrent background builds
      if vim.b.android_debug_job then
        pcall(vim.fn.jobstop, vim.b.android_debug_job)
        vim.b.android_debug_job = nil
      end

      -- Resolve active device and construct dynamic commands
      local device = get_active_device()
      local adb_cmd = 'adb'
      local run_flags = ''
      if device then
        adb_cmd = 'adb -s ' .. vim.fn.shellescape(device)
        run_flags = ' --device ' .. vim.fn.shellescape(device)
      end

      -- Obtain the current PID to prevent attaching to a stale process
      local old_pid = vim.fn.system(adb_cmd .. ' shell pidof -s ' .. vim.fn.shellescape(pkg)):gsub('%s+', '')

      local function forward_and_attach(pid)
        vim.fn.system(adb_cmd .. ' forward --remove tcp:5005 2>/dev/null')
        local forward_out = vim.fn.system(adb_cmd .. ' forward tcp:5005 jdwp:' .. pid)
        if vim.v.shell_error ~= 0 then
          vim.notify('ADB Forward failed: ' .. vim.trim(forward_out), vim.log.levels.ERROR)
          return
        end

        vim.notify('Forwarded tcp:5005 → PID ' .. pid .. '. Attaching debugger…')
        if ok_dap then
          dap.run({
            type = 'kotlin',
            request = 'attach',
            name = 'Android Attach',
            hostName = 'localhost',
            port = 5005,
            timeout = 10000,
            projectRoot = root_dir,
          })
        else
          vim.notify('DAP unavailable', vim.log.levels.WARN)
        end
      end

      local function wait_for_pid(tries)
        tries = tries or 0
        local pid = vim.fn.system(adb_cmd .. ' shell pidof -s ' .. vim.fn.shellescape(pkg)):gsub('%s+', '')
        
        -- PID must be non-empty AND different from old_pid to ensure we attach to the restarted app
        if pid ~= '' and pid ~= old_pid then
          forward_and_attach(pid)
        elseif tries < 15 then
          vim.defer_fn(function() wait_for_pid(tries + 1) end, 1000)
        else
          vim.notify('App process not found after 15s (' .. pkg .. ')', vim.log.levels.ERROR)
        end
      end

      -- Evaluate dynamic APK path
      local apk = find_debug_apk()
      if not apk then
        apk = is_cccis and (root_dir .. '/app/build/outputs/apk/firebaseCt/debug/app-firebaseCt-debug.apk')
                       or (root_dir .. '/app/build/outputs/apk/debug/app-debug.apk')
      end

      local cmd = gradlew .. ' ' .. task .. ' && android run --debug' .. run_flags .. ' --apks ' .. vim.fn.shellescape(apk)
      vim.notify('Building & deploying (' .. task .. ') for ' .. pkg .. '…')

      local output = {}
      local function collect(_, data)
        if data then
          for _, line in ipairs(data) do
            if line ~= '' then
              output[#output + 1] = line
            end
          end
        end
      end

      vim.b.android_debug_job = vim.fn.jobstart(cmd, {
        stdout_buffered = false,
        on_stdout = collect,
        on_stderr = collect,
        on_exit = function(_, code)
          vim.b.android_debug_job = nil
          if code == 0 then
            vim.defer_fn(function() wait_for_pid(0) end, 1000)
          else
            vim.schedule(function()
              vim.notify('Build/deploy failed (exit ' .. code .. ')', vim.log.levels.ERROR)
              vim.cmd 'botright new'
              local buf = vim.api.nvim_get_current_buf()
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
              vim.bo[buf].buftype = 'nofile'
              vim.bo[buf].bufhidden = 'wipe'
              vim.bo[buf].modifiable = false
            end)
          end
        end,
      })
    end, { buffer = 0, desc = '[G]radle [D]ebug run on device (auto port-forward + DAP)' })

    -- Fast restart & re-attach (no rebuild): kill target app, launch in debug-wait mode, and re-attach DAP
    vim.keymap.set('n', '<leader>gX', function()
      local pkg = get_package()
      if not pkg then
        vim.notify('Could not determine app package', vim.log.levels.ERROR)
        return
      end

      -- Resolve active device
      local device = get_active_device()
      local adb_cmd = 'adb'
      if device then
        adb_cmd = 'adb -s ' .. vim.fn.shellescape(device)
      end

      -- Resolve launcher activity
      local activity = vim.fn.system(adb_cmd .. " shell cmd package resolve-activity --brief -c android.intent.category.LAUNCHER " .. vim.fn.shellescape(pkg)):gsub('%s+', '')
      if activity == '' or activity:match('No activity found') then
        vim.notify('Could not resolve launcher activity for ' .. pkg, vim.log.levels.ERROR)
        return
      end

      -- Terminate any active DAP session
      local ok_dap, dap = pcall(require, 'dap')
      if ok_dap and dap.session() then
        dap.terminate()
      end

      -- Obtain the current PID before we stop the process
      local old_pid = vim.fn.system(adb_cmd .. ' shell pidof -s ' .. vim.fn.shellescape(pkg)):gsub('%s+', '')

      vim.notify('Restarting ' .. pkg .. ' in debug mode (no rebuild)…')

      -- Force stop the app and start it in debug-wait (-D) mode
      vim.fn.system(adb_cmd .. ' shell am force-stop ' .. vim.fn.shellescape(pkg))
      vim.fn.system(adb_cmd .. ' shell am start -D -n ' .. vim.fn.shellescape(activity))

      local function forward_and_attach(pid)
        vim.fn.system(adb_cmd .. ' forward --remove tcp:5005 2>/dev/null')
        local forward_out = vim.fn.system(adb_cmd .. ' forward tcp:5005 jdwp:' .. pid)
        if vim.v.shell_error ~= 0 then
          vim.notify('ADB Forward failed: ' .. vim.trim(forward_out), vim.log.levels.ERROR)
          return
        end

        vim.notify('Forwarded tcp:5005 → PID ' .. pid .. '. Attaching debugger…')
        if ok_dap then
          dap.run({
            type = 'kotlin',
            request = 'attach',
            name = 'Android Attach',
            hostName = 'localhost',
            port = 5005,
            timeout = 10000,
            projectRoot = root_dir,
          })
        else
          vim.notify('DAP unavailable', vim.log.levels.WARN)
        end
      end

      local function wait_for_pid(tries)
        tries = tries or 0
        local pid = vim.fn.system(adb_cmd .. ' shell pidof -s ' .. vim.fn.shellescape(pkg)):gsub('%s+', '')
        
        -- PID must be non-empty AND different from old_pid to ensure we attach to the restarted app
        if pid ~= '' and pid ~= old_pid then
          forward_and_attach(pid)
        elseif tries < 15 then
          vim.defer_fn(function() wait_for_pid(tries + 1) end, 500)
        else
          vim.notify('App process not found after restart (' .. pkg .. ')', vim.log.levels.ERROR)
        end
      end

      -- Start polling for the new PID
      vim.defer_fn(function() wait_for_pid(0) end, 500)
    end, { buffer = 0, desc = '[G]radle [X] fast restart and re-attach DAP (no rebuild)' })

    -- Pick an AVD from the list and start it
    vim.keymap.set('n', '<leader>ge', function()
      local avds = vim.tbl_filter(function(l)
        return l ~= ''
      end, vim.fn.systemlist 'android emulator list 2>/dev/null')
      if #avds == 0 then
        vim.notify('No AVDs found', vim.log.levels.WARN)
        return
      end
      vim.ui.select(avds, { prompt = 'Start emulator:' }, function(choice)
        if choice then
          vim.fn.jobstart({ 'android', 'emulator', 'start', choice }, { detach = true })
          vim.notify('Starting ' .. choice .. '…')
        end
      end)
    end, { buffer = 0, desc = '[G]radle [E]mulator start' })

    -- Capture device screenshot and open with Quick Look
    vim.keymap.set('n', '<leader>gS', function()
      local path = '/tmp/android_screen_' .. os.time() .. '.png'
      local out = vim.fn.system('android screen capture -o ' .. vim.fn.shellescape(path) .. ' 2>&1')
      if vim.v.shell_error == 0 then
        vim.notify('Screenshot → ' .. path)
        vim.fn.jobstart({ 'qlmanage', '-p', path }, { detach = true })
      else
        vim.notify('Screenshot failed: ' .. vim.trim(out), vim.log.levels.ERROR)
      end
    end, { buffer = 0, desc = '[G]radle [S]creenshot (Quick Look)' })

    -- Dump live UI layout tree into a JSON scratch buffer
    vim.keymap.set('n', '<leader>gL', function()
      local out = vim.fn.system 'android layout --pretty 2>&1'
      if vim.v.shell_error ~= 0 then
        vim.notify('Layout dump failed: ' .. vim.trim(out), vim.log.levels.ERROR)
        return
      end
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].filetype = 'json'
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(out, '\n'))
      vim.bo[buf].modifiable = false
      vim.cmd 'split'
      vim.api.nvim_win_set_buf(0, buf)
    end, { buffer = 0, desc = '[G]radle [L]ayout dump (UI tree JSON)' })

    -- Search Android developer docs in a terminal split
    vim.keymap.set('n', '<leader>gA', function()
      vim.ui.input({ prompt = 'Android docs: ' }, function(query)
        if query and query ~= '' then
          vim.cmd('split | terminal android docs search ' .. vim.fn.shellescape(query))
        end
      end)
    end, { buffer = 0, desc = '[G]radle [A]ndroid docs search' })

    -- Command to force re-discovery of install tasks
    vim.api.nvim_create_user_command('AndroidTaskReset', function()
      project_config.load_config(root_dir)
      local config = project_config.load_config(root_dir) or {}
      config.install_task = nil
      project_config.save_config(root_dir, config)
      vim.g[init_key] = false
      vim.notify 'Install task config cleared. Re-discovery will happen on next Kotlin file open.'
    end, { desc = 'Reset saved Android install task' })

    -- Command to set APK variant (e.g., firebaseCt, debug, release)
    vim.api.nvim_create_user_command('AndroidSetVariant', function(opts)
      local variant = opts.args:match '^%s*(.-)%s*$'
      if variant == '' then
        vim.notify('Usage: AndroidSetVariant <variant> (e.g., firebaseCt, debug)', vim.log.levels.WARN)
        return
      end
      local config = project_config.load_config(root_dir) or {}
      config.apk_variant = variant
      project_config.save_config(root_dir, config)
      vim.notify('APK variant set to: ' .. variant)
    end, { nargs = 1, desc = 'Set Android APK variant (firebaseCt, debug, etc.)' })
  end
end
