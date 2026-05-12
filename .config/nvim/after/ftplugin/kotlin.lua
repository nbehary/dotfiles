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
local root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew' }, { upward = true })[1])
if root_dir then
  local gradlew = root_dir .. '/gradlew'
  local project_config = require 'android.project_config'
  local task_discovery = require 'android.task_discovery'

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

  -- android CLI integration
  if vim.fn.executable 'android' == 1 then
    -- Find the debug APK: check conventional path first, then glob
    local function find_debug_apk()
      local conventional = root_dir .. '/app/build/outputs/apk/firebaseCt/debug/app-firebase-ct-debug.apk'
      if vim.fn.filereadable(conventional) == 1 then
        return conventional
      end
      local found = vim.fn.glob(root_dir .. '/**/apk/firebaseCt/debug/*.apk', false, true)
      return found[1]
    end

    local default_apk = root_dir .. '/app/build/outputs/apk/firebaseCt/debug/app-firebase-ct-debug.apk'

    -- Build with hardcoded task, then deploy and launch on connected device
    vim.keymap.set('n', '<leader>gr', function()
      vim.cmd('!' .. gradlew .. ' installFirebaseCtDebug && android run --apks ' .. vim.fn.shellescape(default_apk))
    end, { buffer = 0, desc = '[G]radle [R]un on device (build + deploy)' })

    -- Deploy existing APK without rebuilding
    vim.keymap.set('n', '<leader>gR', function()
      local apk = find_debug_apk()
      if not apk then
        vim.notify('No debug APK found — build first with <leader>gb', vim.log.levels.WARN)
        return
      end
      vim.cmd('!android run --apks ' .. vim.fn.shellescape(apk))
    end, { buffer = 0, desc = '[G]radle [R]edeploy (no build)' })

    -- Build assembleDebug, then deploy in debug mode (waits for debugger attach)
    vim.keymap.set('n', '<leader>gD', function()
      vim.cmd('!' .. gradlew .. ' assembleDebug && android run --debug --apks ' .. vim.fn.shellescape(default_apk))
    end, { buffer = 0, desc = '[G]radle [D]ebug run on device' })

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
  end
end
