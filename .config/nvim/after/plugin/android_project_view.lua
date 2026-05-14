-- Setup android_project_view and map <leader>ap to toggle the sidebar
pcall(function()
  require('android_project_view').setup()
  vim.keymap.set('n', '<leader>ap', '<cmd>AndroidProjectViewToggle<cr>', { desc = '[A]ndroid [P]roject view' })
end)
