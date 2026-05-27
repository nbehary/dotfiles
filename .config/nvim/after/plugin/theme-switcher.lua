-- ============================================================================
-- Themery & Color-Chameleon Coexistence Configuration
-- ============================================================================

-- 1. Setup Themery (Manual Theme Switcher)
pcall(function()
  require('themery').setup {
    themes = {
      'kanagawa',
      'tokyonight',
      'rose-pine',
      'nightfox',
      'cyberdream',
      'everforest',
      'gruvbox-material',
      'catppuccin',
    },
    livePreview = true,
  }

  -- Keybinding to open Themery picker
  vim.keymap.set('n', '<leader>th', '<cmd>Themery<cr>', { desc = 'Open Themery (Theme Switcher)' })
end)

-- 2. Setup Color-Chameleon (Automated Context-Based Switcher)
pcall(function()
  -- Define the fallback rule first so the condition function can dynamically update its colorscheme
  local fallback_rule = {
    colorscheme = 'kanagawa',
    condition = function()
      local ok_themery, themery = pcall(require, 'themery')
      if ok_themery then
        local current = themery.get_current_theme()
        if current and current.name then
          fallback_rule.colorscheme = current.name
        end
      end
      return true -- Always matches as the default fallback
    end,
  }

  require('color-chameleon').setup {
    rules = {
      -- Example Rule 1: Visual indicator for editing sensitive configurations (e.g. dotfiles directory uses nightfox)
      -- { path = { "~/working_dotfiles" }, colorscheme = "nightfox" },

      -- Example Rule 2: Cozy aesthetic specifically for Git commits
      { filetype = { 'gitcommit' }, colorscheme = 'rose-pine' },
      { filetype = { 'kt', 'java', 'gradle' }, colorscheme = 'nightfox' },

      -- Dynamic Fallback Rule (Syncs with Themery manual selections)
      fallback_rule,
    },
    -- Use kanagawa as the ultimate fallback in case of exceptions
    default = 'kanagawa',
  }
end)
