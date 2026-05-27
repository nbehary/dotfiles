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

-- Setup android-variant-picker plugin keymaps dynamically
local ok, picker = pcall(require, 'android-variant-picker')
if ok then
  picker.register_keymaps(0)
else
  vim.notify('android-variant-picker plugin not loaded. Run scripts/install-nvim-plugins.sh to install.', vim.log.levels.WARN)
end

