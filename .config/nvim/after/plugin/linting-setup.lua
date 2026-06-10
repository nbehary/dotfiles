-- Linting Configuration (nvim-lint)
-- Provides real diagnostics from ktlint for Kotlin files

local lint = require('lint')

lint.linters_by_ft = {
  kotlin = { 'ktlint' },
}

if lint.linters.ktlint then
  local ktlint_path = os.getenv('HOME') .. '/.local/share/nvim/mason/bin/ktlint'
  lint.linters.ktlint.cmd = ktlint_path
  lint.linters.ktlint.args = { '--reporter=json', '--stdin' }
end

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('lint', { clear = true }),
  callback = function()
    lint.try_lint()
  end,
})

vim.keymap.set('n', '<leader>li', function()
  lint.try_lint()
end, { desc = '[L]int [I]ssues (manual)' })
