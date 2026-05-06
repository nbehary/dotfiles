# Neovim Plugin Keybindings Cheat Sheet

Leader = `<Space>`. Modes: `n` normal, `i` insert, `v` visual, `t` terminal.

## Telescope (`nvim-telescope/telescope.nvim`)

| Keys | Action |
| --- | --- |
| `<leader>sh` | Search help tags |
| `<leader>sk` | Search keymaps |
| `<leader>sf` | Search files |
| `<leader>ss` | Search Telescope builtins |
| `<leader>sw` | Search current word |
| `<leader>sg` | Live grep |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Resume last picker |
| `<leader>s.` | Recent files |
| `<leader>s/` | Live grep in open files |
| `<leader>sn` | Search Neovim config files |
| `<leader><leader>` | Find existing buffers |
| `<leader>/` | Fuzzy find in current buffer |

## Harpoon (`theprimeagen/harpoon`)

| Keys | Action |
| --- | --- |
| `<leader>a` | Add current file to harpoon |
| `<C-e>` | Toggle quick menu |
| `<leader>1` | Jump to file 1 |
| `<leader>2` | Jump to file 2 |
| `<leader>3` | Jump to file 3 |
| `<leader>4` | Jump to file 4 |

## File trees

### nvim-tree (`nvim-tree/nvim-tree.lua`)

| Keys | Action |
| --- | --- |
| `<leader>pv` | Toggle nvim-tree |

Inside the tree (defaults): `o`/`<CR>` open, `a` create, `d` delete, `r` rename, `x` cut, `c` copy, `p` paste, `R` refresh, `H` toggle hidden, `?` help.

### Oil (`stevearc/oil.nvim`)

| Keys | Action |
| --- | --- |
| `-` | Open parent directory in Oil |
| `<space>-` | Toggle floating Oil window |

Inside Oil (defaults): `<CR>` select, `<C-p>` preview, `<C-c>` close, `-` go up, `g?` help, `<M-h>` open in split (custom).

## Git

### Gitsigns (`lewis6991/gitsigns.nvim`)

| Keys | Action |
| --- | --- |
| `<leader>gp` | Preview hunk |
| `<leader>gb` | Toggle current line blame |

### Lazygit (`kdheepak/lazygit.nvim`)

| Keys | Action |
| --- | --- |
| `<leader>lg` | Open LazyGit |

### Neogit (`NeogitOrg/neogit`)

No custom keymaps. Use `:Neogit` to open.

## Undotree (`mbbill/undotree`)

| Keys | Action |
| --- | --- |
| `<leader>u` | Toggle undotree |

## Floaterm (`voldikss/vim-floaterm`)

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>;` | n, t | Toggle floating terminal |
| `<leader>fn` | n, t | New floating terminal |
| `<leader>f]` | n, t | Next floating terminal |
| `<leader>f[` | n, t | Previous floating terminal |
| `<leader>fk` | n, t | Kill floating terminal |

## Claude Code (`coder/claudecode.nvim`)

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>ac` | n | Toggle Claude |
| `<leader>af` | n | Focus Claude |
| `<leader>ar` | n | Resume Claude |
| `<leader>aC` | n | Continue Claude |
| `<leader>am` | n | Select Claude model |
| `<leader>ab` | n | Add current buffer |
| `<leader>as` | v | Send selection to Claude |
| `<leader>as` | n | Add file (in tree/oil/netrw buffers) |
| `<leader>aa` | n | Accept diff |
| `<leader>ad` | n | Deny diff |

## Conform (`stevearc/conform.nvim`)

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>l` | n, v | Format file or range |

Also formats automatically on save.

## LSP (active when an LSP attaches)

| Keys | Action |
| --- | --- |
| `gd` | Goto definition (Telescope) |
| `gr` | Goto references (Telescope) |
| `gI` | Goto implementation (Telescope) |
| `gD` | Goto declaration |
| `<leader>D` | Type definition |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `K` | Hover documentation |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>e` | Show diagnostic float |
| `<leader>q` | Diagnostic quickfix list |

## nvim-cmp (`hrsh7th/nvim-cmp`) — insert mode

| Keys | Action |
| --- | --- |
| `<C-n>` | Next completion item |
| `<C-p>` | Previous completion item |
| `<C-y>` | Confirm selection |
| `<C-Space>` | Trigger completion |
| `<C-l>` | Expand snippet / jump forward |
| `<C-h>` | Jump backward in snippet |

## Comment.nvim (`numToStr/Comment.nvim`)

Plugin defaults:

| Keys | Mode | Action |
| --- | --- | --- |
| `gcc` | n | Toggle line comment |
| `gbc` | n | Toggle block comment |
| `gc` | v | Toggle line comment on selection |
| `gb` | v | Toggle block comment on selection |
| `gco` / `gcO` / `gcA` | n | Add comment below / above / end of line |

## mini.nvim

### mini.ai (text objects, defaults)

Use with `a`/`i` operators, e.g. `dab`, `ci)`, `vaq`. Adds smarter targets like `a)`, `i]`, `aq` (quote), `at` (tag), `af` (function call), `ac` (class), plus `n`/`l` for next/last (e.g. `cinq` change inside next quote).

### mini.surround (defaults)

| Keys | Mode | Action |
| --- | --- | --- |
| `sa` | n, v | Add surrounding (`saiw)` → wrap word in `()`) |
| `sd` | n | Delete surrounding |
| `sr` | n | Replace surrounding |
| `sf` / `sF` | n | Find surrounding right / left |
| `sh` | n | Highlight surrounding |
| `sn` | n | Update n_lines |

### mini.statusline

No keybindings (UI only).

## todo-comments (`folke/todo-comments.nvim`)

No custom keymaps. Useful commands: `:TodoTelescope`, `:TodoQuickFix`, `:TodoLocList`.

## edgy (`folke/edgy.nvim`)

No custom keymaps. Commands: `:Edgy`, `:EdgyToggle`, `:EdgyClose`.

## Diffview (`sindrets/diffview.nvim`)

No custom keymaps. Commands: `:DiffviewOpen`, `:DiffviewClose`, `:DiffviewFileHistory`.

## glslView (`timtro/glslView-nvim`)

No custom keymaps. Use `:GlslView` to launch.

## Tidal (`tidalcycles/vim-tidal`)

Plugin defaults (in Tidal files): `<C-e>` send line, `<C-c><C-c>` send block, `<leader>h` hush.

## Snacks / fidget / mason / web-devicons / plenary

No user-facing keymaps.

---

## Non-plugin reference (built-in keymaps from `init.lua`)

| Keys | Mode | Action |
| --- | --- | --- |
| `jk` | i | Escape to normal mode |
| `<Esc>` | n | Clear search highlight |
| `<Esc><Esc>` | t | Exit terminal mode |
| `<C-h/j/k/l>` | n | Move between windows |
