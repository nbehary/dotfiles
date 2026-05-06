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

require('jdtls_start') { java_keymaps = true }
