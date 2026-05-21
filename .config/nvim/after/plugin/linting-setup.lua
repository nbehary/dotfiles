-- Linting Configuration (nvim-lint)
-- Provides real diagnostics from ktlint for Kotlin files

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('lint', { clear = true }),
  callback = function()
    local ok, lint = pcall(require, 'lint')
    if not ok then
      return
    end

    -- Configure ktlint linter for Kotlin
    lint.linters_by_ft = {
      kotlin = { 'ktlint' },
    }

    if lint.linters.ktlint then
      lint.linters.ktlint.args = {
        '--android',
        '--reporter=json',
      }
    end

    lint.try_lint()
  end,
})

vim.keymap.set('n', '<leader>li', function()
  local ok, lint = pcall(require, 'lint')
  if ok then
    lint.try_lint()
  end
end, { desc = '[L]int [I]ssues (manual)' })
