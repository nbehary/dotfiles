-- Formatting Configuration (conform.nvim)

local conform = require 'conform'

conform.setup {
  formatters_by_ft = {
    lua = { 'stylua' },
    kotlin = { 'ktlint' },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>l', function()
  conform.format {
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  }
end, { desc = 'Format file or range (in visual mode)' })
