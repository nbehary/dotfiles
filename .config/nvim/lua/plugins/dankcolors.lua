return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#1c1c1c',
				base01 = '#1c1c1c',
				base02 = '#767e7b',
				base03 = '#767e7b',
				base04 = '#a2ada9',
				base05 = '#e9efec',
				base06 = '#e9efec',
				base07 = '#e9efec',
				base08 = '#dea58b',
				base09 = '#dea58b',
				base0A = '#95b5a9',
				base0B = '#80c683',
				base0C = '#d1e7de',
				base0D = '#95b5a9',
				base0E = '#b7d6ca',
				base0F = '#b7d6ca',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#767e7b',
				fg = '#e9efec',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#95b5a9',
				fg = '#1c1c1c',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#767e7b' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#d1e7de', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#b7d6ca',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#95b5a9',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#95b5a9',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#d1e7de',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#80c683',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#a2ada9' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#a2ada9' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#767e7b',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
