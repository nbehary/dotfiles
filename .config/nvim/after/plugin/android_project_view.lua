-- Setup android_project_view and map <leader>ap to toggle the sidebar
local ok, ap = pcall(require, 'android_project_view')
if not ok then
  -- Try to load optional plugin from pack/*/opt via packadd, then require again.
  pcall(vim.cmd, 'packadd android_project_view')
  ok, ap = pcall(require, 'android_project_view')
end

if ok and ap then
  pcall(function() ap.setup() end)
  vim.keymap.set('n', '<leader>ap', function()
    vim.cmd('AndroidProjectViewToggle')
    pcall(vim.cmd, 'AndroidProjectViewFocus')
    -- fallback: focus window whose buffer filetype looks like the android project view
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local bufnr = vim.api.nvim_win_get_buf(win)
      local ok, ft = pcall(vim.api.nvim_buf_get_option, bufnr, 'filetype')
      if ok and ft then
        local lft = ft:lower()
        if lft:find('android') or lft:find('project') then
          vim.api.nvim_set_current_win(win)
          break
        end
      end
    end
  end, { desc = '[A]ndroid [P]roject view toggle and focus' })
else
  vim.keymap.set('n', '<leader>ap', function()
    vim.notify('android_project_view plugin not found. Run scripts/install-nvim-plugins.sh to install required plugins.', vim.log.levels.WARN)
  end, { desc = '[A]ndroid [P]roject view (plugin missing)' })
end
