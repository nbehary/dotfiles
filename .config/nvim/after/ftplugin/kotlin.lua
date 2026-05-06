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

  vim.keymap.set('n', '<leader>gb', function()
    vim.cmd('!' .. gradlew .. ' assembleDebug')
  end, { buffer = 0, desc = '[G]radle [B]uild (assembleDebug)' })

  vim.keymap.set('n', '<leader>gt', function()
    vim.cmd('!' .. gradlew .. ' test')
  end, { buffer = 0, desc = '[G]radle [T]est' })

  vim.keymap.set('n', '<leader>gc', function()
    vim.cmd('!' .. gradlew .. ' clean')
  end, { buffer = 0, desc = '[G]radle [C]lean' })

  vim.keymap.set('n', '<leader>gr', function()
    local apk = root_dir .. '/app/build/outputs/apk/debug/app-debug.apk'
    vim.cmd('!' .. gradlew .. ' assembleDebug && android run --apks ' .. apk)
  end, { buffer = 0, desc = '[G]radle [R]un (build + install)' })
end
