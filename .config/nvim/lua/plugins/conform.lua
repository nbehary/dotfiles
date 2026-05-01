-- Merged from two duplicate conform.nvim entries in old lazy config.
require('conform').setup {
  notify_on_error = false,
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
  formatters_by_ft = {
    lua = { 'stylua' },
    kotlin = { 'ktlint' },
  },
}
vim.keymap.set({ 'n', 'v' }, '<leader>l', function()
  require('conform').format {
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  }
end, { desc = 'Format file or range (in visual mode)' })
