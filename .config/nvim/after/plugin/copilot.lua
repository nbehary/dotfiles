-- GitHub Copilot Configuration
vim.g.copilot_no_tab_map = true

vim.keymap.set('i', '<C-u>', 'copilot#Accept("")', {
  expr = true,
  replace_keycodes = false,
  silent = true,
  desc = 'Copilot Accept'
})
