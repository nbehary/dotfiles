-- Setup android-nvim-plugin
local ok, android = pcall(require, 'android')
if ok then
  android.setup({
    -- Disable default global keymaps from the plugin so it doesn't interfere
    keymaps = {
      enabled = false,
    },
  })
  
  -- Bind only the logcat part to <leader>al
  vim.keymap.set('n', '<leader>al', '<cmd>AndroidLogcat<CR>', { desc = 'Android Logcat (plugin)' })
else
  vim.notify('android-nvim-plugin not loaded.', vim.log.levels.WARN)
end
