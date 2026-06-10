-- Setup android-nvim-plugin
local ok, android = pcall(require, 'android')
if ok then
  android.setup({
    -- Disable default global keymaps from the plugin so it doesn't interfere
    keymaps = {
      enabled = false,
    },
  })
  
  -- Android keymaps
  vim.keymap.set('n', '<leader>am', '<cmd>AndroidMenu<CR>', { desc = 'Android Menu' })
  vim.keymap.set('n', '<leader>aa', '<cmd>AndroidActions<CR>', { desc = 'Android Actions (ADB)' })
  vim.keymap.set('n', '<leader>al', '<cmd>AndroidLogcat<CR>', { desc = 'Android Logcat' })
else
  vim.notify('android-nvim-plugin not loaded.', vim.log.levels.WARN)
end
