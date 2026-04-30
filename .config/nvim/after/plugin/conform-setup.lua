-- Formatting Configuration (conform.nvim)
-- Defer until conform is available

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('conform-setup', { clear = true }),
  callback = function()
    local ok, conform = pcall(require, 'conform')
    if not ok then
      return
    end

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
  end,
  once = true,
})
