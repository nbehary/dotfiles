-- Claude Code integration (coder/claudecode.nvim)
-- Implements the same WebSocket/MCP IDE protocol as the official VS Code
-- extension: Claude sees your current selection, and its proposed edits open
-- as native Neovim diffs you can accept or deny.
-- Requires the `claude` CLI on PATH.
--
-- NOTE: <leader>a is shared with the Android maps (aa/ab/ad/ag/al/am/ao/ap/at),
-- so the diff accept/deny use ay ("yes") / an ("no") instead of the plugin's
-- suggested aa/ad.
pcall(function()
  require('claudecode').setup {
    terminal = {
      split_side = 'right',
      split_width_percentage = 0.35,
    },
  }

  local map = vim.keymap.set
  map('n', '<leader>ai', '<cmd>ClaudeCode<cr>', { desc = 'Claude Code toggle' })
  map('t', '<leader>ai', '<cmd>ClaudeCode<cr>', { desc = 'Claude Code toggle' })
  map('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Claude Code focus' })
  map('n', '<leader>ar', '<cmd>ClaudeCode --resume<cr>', { desc = 'Claude Code resume session' })
  map('n', '<leader>aC', '<cmd>ClaudeCode --continue<cr>', { desc = 'Claude Code continue session' })

  -- Context: send visual selection, or add the current file in normal mode
  map('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send selection to Claude' })
  map('n', '<leader>as', '<cmd>ClaudeCodeAdd %<cr>', { desc = 'Add current file to Claude context' })

  -- Diff review for edits Claude proposes
  map('n', '<leader>ay', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Claude diff: accept (yes)' })
  map('n', '<leader>an', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = 'Claude diff: deny (no)' })

  -- In file explorers, <leader>as adds the file under the cursor instead
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'NvimTree', 'oil', 'minifiles' },
    callback = function(args)
      vim.keymap.set('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>',
        { buffer = args.buf, desc = 'Add file to Claude context' })
    end,
  })
end)
