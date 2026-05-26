-- Setup android_project_view and map <leader>ap to toggle the sidebar
local ok, ap = pcall(require, 'android_project_view')
if ok and ap then
  pcall(function() ap.setup() end)
  vim.keymap.set('n', '<leader>ap', '<cmd>AndroidProjectViewToggle<cr>', { desc = '[A]ndroid [P]roject view' })
else
  vim.keymap.set('n', '<leader>ap', function()
    vim.notify('android_project_view plugin not found. Run scripts/install-nvim-plugins.sh to install required plugins.', vim.log.levels.WARN)
  end, { desc = '[A]ndroid [P]roject view (plugin missing)' })
end
