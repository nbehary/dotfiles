-- Minimal configuration for kokusenz/delta.lua
-- Safe: only configures the plugin when available.
local ok, delta = pcall(require, 'delta')
if not ok then
  vim.notify('delta.lua not found', vim.log.levels.WARN)
  return
end

if type(delta.setup) == 'function' then
  delta.setup({
    -- sensible defaults; tweak as desired
    width = 80,
    side = 'right',
    border = 'rounded',
    diagnostics = true,
  })
end

-- Example keymap: prefer an "open" or "toggle" method if available
if type(delta.open) == 'function' then
  vim.keymap.set('n', '<leader>dd', delta.open, { noremap = true, silent = true, desc = 'Open Delta' })
elseif type(delta.toggle) == 'function' then
  vim.keymap.set('n', '<leader>dd', delta.toggle, { noremap = true, silent = true, desc = 'Toggle Delta' })
end

-- Map <leader>da to open Delta for changed files (prefer working-tree changes; fall back to last commit)
vim.keymap.set('n', '<leader>da', function()
  -- Determine git repo root; fall back to cwd when not in a git repo
  local root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if root == nil or root == '' then
    root = vim.fn.getcwd()
  end

  -- Helper to run git in repo root
  local function git_list(args)
    local cmd = 'git -C ' .. vim.fn.shellescape(root) .. ' ' .. args
    local out = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
      return {}
    end
    return out
  end

  -- Prefer pending (working-tree + staged) changes
  local pending = git_list('diff --name-only HEAD')
  local staged = git_list('diff --name-only --cached')

  local file_set = {}
  for _, f in ipairs(pending) do if f and f ~= '' then file_set[f] = true end end
  for _, f in ipairs(staged) do if f and f ~= '' then file_set[f] = true end end

  local changed = {}
  for f, _ in pairs(file_set) do table.insert(changed, f) end

  local used_last_commit = false
  -- If no pending changes, fall back to last commit
  if #changed == 0 then
    changed = git_list('diff --name-only HEAD~1 HEAD')
    used_last_commit = true
  end

  if not changed or #changed == 0 then
    vim.notify('No changed files found (working tree or last commit)', vim.log.levels.INFO)
    return
  end

  -- For each changed file, open the file buffer first, then open a Delta view for that file
  for _, f in ipairs(changed) do
    local rel = f
    local abs = f
    if string.sub(abs, 1, 1) ~= '/' then
      abs = root .. '/' .. f
    end

    -- Temporarily suppress noisy output (print/notify/echo/out_write/err_writeln) while opening diffs
    local orig_print = print
    local orig_notify = vim.notify
    local orig_out_write = vim.api.nvim_out_write
    local orig_err_writeln = vim.api.nvim_err_writeln
    local orig_echo = vim.api.nvim_echo

    -- Override common output functions
    print = function() end
    vim.notify = function() end
    if vim.api and vim.api.nvim_out_write then vim.api.nvim_out_write = function() end end
    if vim.api and vim.api.nvim_err_writeln then vim.api.nvim_err_writeln = function() end end
    if vim.api and vim.api.nvim_echo then vim.api.nvim_echo = function() end end

    local ok, err
    local orig_notify = vim.notify
    vim.notify = function() end
    local ok, err

    if used_last_commit then
      ok, err = pcall(function()
        -- Open each comparison in its own tab: current file vs HEAD~1 version using Vim's diff
        pcall(vim.cmd, 'tabnew ' .. vim.fn.fnameescape(abs))
        local winA = vim.api.nvim_get_current_win()
        -- Create a vertical split for the previous commit version
        vim.cmd('vsplit')
        local winB = vim.api.nvim_get_current_win()
        -- Create a scratch buffer and populate it with the content from HEAD~1
        local bufB = vim.api.nvim_create_buf(false, true)
        local git_cmd = 'git -C ' .. vim.fn.shellescape(root) .. ' show HEAD~1:' .. vim.fn.shellescape(rel)
        local lines = vim.fn.systemlist(git_cmd)
        if vim.v.shell_error ~= 0 or not lines or #lines == 0 then
          -- If git show failed (e.g., file renamed/deleted), close the tab and return
          pcall(vim.cmd, 'tabclose')
          return
        end
        vim.api.nvim_buf_set_lines(bufB, 0, -1, false, lines)
        vim.api.nvim_win_set_buf(winB, bufB)
        vim.api.nvim_buf_set_option(bufB, 'bufhidden', 'wipe')
        -- Match filetype to the main buffer
        local main_buf = vim.api.nvim_win_get_buf(winA)
        local ft = vim.api.nvim_buf_get_option(main_buf, 'filetype')
        if ft and ft ~= '' then
          vim.api.nvim_buf_set_option(bufB, 'filetype', ft)
        end

        -- Enable diff mode between windows
        vim.api.nvim_set_current_win(winA)
        vim.cmd('diffthis')
        vim.api.nvim_set_current_win(winB)
        vim.cmd('diffthis')
      end)
    else
      ok, err = pcall(function()
        -- Pending changes: open file and use Delta (or fallback to a simple diff of buffer vs HEAD)
        pcall(vim.cmd, 'silent edit ' .. vim.fn.fnameescape(abs))
        local cmd = string.format('Delta %s %d %s', vim.fn.fnameescape(abs), 3, 'HEAD')
        pcall(vim.cmd, cmd)
      end)
    end

    -- Restore originals
    print = orig_print
    vim.notify = orig_notify
    if vim.api and orig_out_write then vim.api.nvim_out_write = orig_out_write end
    if vim.api and orig_err_writeln then vim.api.nvim_err_writeln = orig_err_writeln end
    if vim.api and orig_echo then vim.api.nvim_echo = orig_echo end

    if not ok then
      vim.notify('Error opening diff for ' .. rel .. ': ' .. tostring(err), vim.log.levels.ERROR)
    end
  end
end, { noremap = true, silent = true, desc = 'Delta: open changed files (pending or last commit)' })
