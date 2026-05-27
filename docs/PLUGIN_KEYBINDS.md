# Neovim Plugin Keybinds

_A curated reference of all plugin keybindings in your Neovim configuration._

---

## Core Navigation

### Harpoon
| Keybind | Mode | Action |
|---------|------|--------|
| `<leader>a` | Normal | Add file to harpoon |
| `<C-e>` | Normal | Toggle harpoon menu |
| `<C-h>` | Normal | Navigate to harpoon file 1 |
| `<C-t>` | Normal | Navigate to harpoon file 2 |
| `<C-n>` | Normal | Navigate to harpoon file 3 |
| `<C-s>` | Normal | Navigate to harpoon file 4 |
| `<leader>hc` | Normal | Clear all harpoon marks |

### Leap (Motion)
| Keybind | Mode | Action |
|---------|------|--------|
| `s` | Normal/Visual/Operator | Leap forward |
| `S` | Normal/Visual/Operator | Leap from window |

### Oil (File Browser)
| Keybind | Mode | Action |
|---------|------|--------|
| `-` | Normal | Open parent directory |
| `<space>-` | Normal | Toggle floating oil window |

---

## Terminal & Workspace

### Floaterm (Floating Terminal)
| Keybind | Mode | Action |
|---------|------|--------|
| `<leader>;` | Normal/Terminal | Toggle floating terminal |
| `<leader>T` | Normal/Terminal | New floating terminal |
| `]t` | Normal/Terminal | Next floating terminal |
| `[t` | Normal/Terminal | Prev floating terminal |

---

## Code Editing & Refactoring

### Aerial (Code Structure)
| Keybind | Mode | Action |
|---------|------|--------|
| `<leader>cs` | Normal | Toggle code structure (Aerial) |
| `<leader>cn` | Normal | Toggle code navigation (Aerial) |

### Java (jdtls)
| Keybind | Mode | Action |
|---------|------|--------|
| `<leader>co` | Normal | Organize imports |
| `<leader>cv` | Normal | Extract variable |
| `<leader>cv` | Visual | Extract variable |
| `<leader>ce` | Normal | Extract constant |
| `<leader>ce` | Visual | Extract constant |
| `<leader>cm` | Visual | Extract method |

### Kotlin (Language-specific)
| Keybind | Mode | Action |
|---------|------|--------|
| `<leader>gb` | Normal | Gradle build (assembleDebug) |
| `<leader>gt` | Normal | Gradle test |
| `<leader>gc` | Normal | Gradle clean |
| `<leader>gr` | Normal | Gradle run on device (build + deploy) |
| `<leader>gR` | Normal | Deploy existing APK (no rebuild) |
| `<leader>gD` | Normal | Gradle debug run on device |
| `<leader>ge` | Normal | Pick AVD and start emulator |
| `<leader>gS` | Normal | Capture device screenshot |
| `<leader>gL` | Normal | Dump UI layout tree to buffer |
| `<leader>gA` | Normal | Search Android developer docs |

### Conform (Formatting)
| Keybind | Mode | Action |
|---------|------|--------|
| `<leader>l` | Normal/Visual | Format code |

---

## LSP & Diagnostics

### LSP Server
| Keybind | Mode | Action |
|---------|------|--------|
| `<leader>D` | Normal | Type definition |
| `<leader>ds` | Normal | Document symbols |
| `<leader>ws` | Normal | Workspace symbols |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>ca` | Normal | Code action |

### Git Integration

### Gitsigns (Git Signs)
| Keybind | Mode | Action |
|---------|------|--------|
| `<leader>gp` | Normal | Preview git hunk |
| `<leader>gl` | Normal | Toggle git blame |

---

## AI & Chat

### Copilot Chat
| Keybind | Mode | Action |
|---------|------|--------|
| `<leader>ai` | Normal | CopilotChat |
| `<leader>ai` | Visual | CopilotChat |

### CodeCompanion
| Keybind | Mode | Action |
|---------|------|--------|
| `<leader>cc` | Normal | CodeCompanion chat |
| `<leader>cc` | Visual | CodeCompanion chat |
| `<leader>ca` | Normal | CodeCompanion actions |
| `<leader>ca` | Visual | CodeCompanion actions |

---

## Debugging

### DAP (Debug Adapter Protocol)
| Keybind | Mode | Action |
|---------|------|--------|
| `<F5>` | Normal | Debug: Start/Continue |
| `<F1>` | Normal | Debug: Step Into |
| `<F2>` | Normal | Debug: Step Over |
| `<F3>` | Normal | Debug: Step Out |
| `<F7>` | Normal | Debug: Toggle UI |
| `<leader>b` | Normal | Debug: Toggle Breakpoint |
| `<leader>B` | Normal | Debug: Set Conditional Breakpoint |

### Android Debug
| Keybind | Mode | Action |
|---------|------|--------|
| `<F9>` | Normal | Android Debug |
| `<leader>dr` | Normal | Android Run (no debugger) |
| `<leader>al` | Normal | Android Studio-like Logcat Viewer |
| `<leader>ag` | Normal | Android Gradle tasks |

---

## Utility

### Undotree
| Keybind | Mode | Action |
|---------|------|--------|
| `<leader>u` | Normal | Toggle undotree |

---

**Legend:**
- `<leader>` = Space key
- `<C-x>` = Ctrl + x
- `<F5>` = Function key
- **Mode:** Normal = Normal mode, Visual = Visual mode, Terminal = Terminal mode, Operator = Operator mode

_Last updated: 2026-05-12_
175:      vim.keymap.set('n', '<leader>cc', '<cmd>CodeCompanionChat<cr>', { desc = '[C]ode[C]ompanion Chat' })
176:      vim.keymap.set('v', '<leader>cc', '<cmd>CodeCompanionChat<cr>', { desc = '[C]ode[C]ompanion Chat' })
177:      vim.keymap.set('n', '<leader>ca', '<cmd>CodeCompanionActions<cr>', { desc = '[C]ode[C]ompanion [A]ctions' })
178:      vim.keymap.set('v', '<leader>ca', '<cmd>CodeCompanionActions<cr>', { desc = '[C]ode[C]ompanion [A]ctions' })
```

## ./after/plugin/telescope-setup.lua

```
38:    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
39:    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
40:    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
41:    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
42:    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
43:    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
44:    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
45:    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
46:    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
47:    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
49:    vim.keymap.set('n', '<leader>/', function()
56:    vim.keymap.set('n', '<leader>s/', function()
63:    vim.keymap.set('n', '<leader>sn', function()
```

## ./init.lua

```
28:vim.keymap.set('i', 'jk', '<ESC>')
31:vim.keymap.set('n', '<leader>pv', ':NvimTreeToggle<cr>')
34:vim.keymap.set('n', '<leader>n', ':Neogit<cr>', { desc = 'Neogit status' })
37:vim.keymap.set({ 'n', 'v' }, '<leader>Gg', '<cmd>Gradle<cr>', { desc = 'Gradle Projects' })
38:vim.keymap.set({ 'n', 'v' }, '<leader>Gf', '<cmd>GradleFavorites<cr>', { desc = 'Gradle Favorite Commands' })
41:vim.keymap.set('n', '<leader>dw', vim.diagnostic.open_float, { desc = 'Open diagnostics' })
42:vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })
43:vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
44:vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })
45:vim.keymap.set('n', ']e', function()
48:vim.keymap.set('n', '[e', function()
53:vim.keymap.set('n', '<leader>tn', '<cmd>tabnext<cr>', { desc = 'Next tab' })
54:vim.keymap.set('n', '<leader>tp', '<cmd>tabprev<cr>', { desc = 'Prev tab' })
55:vim.keymap.set('n', '<leader>tN', '<cmd>tabnew<cr>', { desc = 'New tab' })
56:vim.keymap.set('n', '<leader>td', '<cmd>tabclose<cr>', { desc = 'Close tab' })
```

## ./lua/jdtls_start.lua

```
89:        vim.keymap.set('n', '<leader>co', jdtls.organize_imports, o)
91:        vim.keymap.set('n', '<leader>cv', jdtls.extract_variable, o)
92:        vim.keymap.set('v', '<leader>cv', function() jdtls.extract_variable(true) end, o)
94:        vim.keymap.set('n', '<leader>cc', jdtls.extract_constant, o)
95:        vim.keymap.set('v', '<leader>cc', function() jdtls.extract_constant(true) end, o)
97:        vim.keymap.set('v', '<leader>cm', function() jdtls.extract_method(true) end, o)
```

## ./lua/kickstart/plugins/debug.lua

```
46:    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
47:    vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
48:    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
49:    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
50:    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
51:    vim.keymap.set('n', '<leader>B', function()
78:    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })
```

## ./pack/github/start/aerial.nvim/lua/aerial/config.lua

```
47:  -- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts OR a table of keymap
```

## ./pack/github/start/aerial.nvim/lua/aerial/fold.lua

```
63:      vim.keymap.set("n", lhs, callback, { buffer = bufnr, desc = desc })
```

## ./pack/github/start/aerial.nvim/lua/aerial/keymap_util.lua

```
27:      vim.keymap.set(mode, k, rhs, vim.tbl_extend("keep", { buffer = bufnr, nowait = true }, opts))
88:  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = bufnr, nowait = true })
89:  vim.keymap.set("n", "<c-c>", "<cmd>close<CR>", { buffer = bufnr })
```

## ./pack/github/start/android-nvim-plugin/lua/android/build/stream.lua

```
174:      vim.keymap.set("n", lhs, fn, { buffer = buffer, silent = true })
```

## ./pack/github/start/android-nvim-plugin/lua/android/config.lua

```
35:      menu = "<leader>am",
36:      targets = "<leader>at",
37:      tools = "<leader>ao",
38:      actions = "<leader>aa",
39:      build = "<leader>ab",
```

## ./pack/github/start/android-nvim-plugin/lua/android/init.lua

```
15:    default_lhs = "<leader>am",
26:    default_lhs = "<leader>at",
37:    default_lhs = "<leader>ao",
48:    default_lhs = "<leader>aa",
59:    default_lhs = "<leader>ab",
153:    vim.keymap.set(
198:        vim.keymap.set(
```

## ./pack/github/start/android-nvim-plugin/lua/android/logcat/session/controls.lua

```
255:      vim.keymap.set("n", lhs, fn, { buffer = buffer, silent = true })
```

## ./pack/github/start/android-nvim-plugin/lua/android/ui/hub.lua

```
224:  vim.keymap.set("n", "q", function()
227:  vim.keymap.set("n", "<Esc>", handle_cancel, { buffer = buf, silent = true })
228:  vim.keymap.set("n", "<Left>", handle_cancel, { buffer = buf, silent = true })
229:  vim.keymap.set("n", "<CR>", select_current, { buffer = buf, silent = true })
230:  vim.keymap.set("n", "<Right>", select_current, { buffer = buf, silent = true })
235:    vim.keymap.set("n", shortcut, function()
240:    vim.keymap.set("n", "/", function()
245:      vim.keymap.set("n", map_key, function()
```

## ./pack/github/start/android-nvim-plugin/lua/android/ui/input.lua

```
79:  vim.keymap.set("i", "<Esc>", function()
```

## ./pack/github/start/android-nvim-plugin/lua/tests/android/setup/command_surface_test.lua

```
58:  vim.keymap.set = keymap_stub
90:    default_lhs = "<leader>am",
96:    default_lhs = "<leader>at",
102:    default_lhs = "<leader>ao",
108:    default_lhs = "<leader>aa",
114:    default_lhs = "<leader>ab",
217:  local original_keymap_set = vim.keymap.set
236:  assert.eq(vim.keymap.set, original_keymap_set, "keymap stub restored")
301:      local is_leader = type(call.lhs) == "string" and call.lhs:find("<leader>", 1, true) == 1
```

## ./pack/github/start/android-nvim-plugin/lua/tests/android/setup/init_test.lua

```
74:  vim.keymap.set = function() end
123:  vim.keymap.set = function() end
172:  vim.keymap.set = function() end
219:  vim.keymap.set = function() end
266:  vim.keymap.set = function() end
313:  vim.keymap.set = function() end
360:  vim.keymap.set = function() end
418:  vim.keymap.set = function() end
475:  vim.keymap.set = function(mode, lhs, rhs, opts)
526:  local menu_map = find_map(calls, "<leader>am")
530:  local targets_map = find_map(calls, "<leader>at")
533:  local tools_map = find_map(calls, "<leader>ao")
536:  local actions_map = find_map(calls, "<leader>aa")
539:  local build_map = find_map(calls, "<leader>ab")
```

## ./pack/github/start/android-nvim-plugin/lua/tests/android/setup/logcat_restore_timing_test.lua

```
107:  vim.keymap.set = function() end
```

## ./pack/github/start/android-nvim-plugin/lua/tests/android/ui/hub/cancel.lua

```
8:  local original_keymap_set = vim.keymap.set
10:  vim.keymap.set = function(_, lhs, rhs)
29:  vim.keymap.set = original_keymap_set
37:  local original_keymap_set = vim.keymap.set
39:  vim.keymap.set = function(_, lhs, rhs)
58:  vim.keymap.set = original_keymap_set
66:  local original_keymap_set = vim.keymap.set
68:  vim.keymap.set = function(_, lhs, rhs)
88:  vim.keymap.set = original_keymap_set
```

## ./pack/github/start/android-nvim-plugin/lua/tests/android/ui/hub/search.lua

```
12:  local original_keymap_set = vim.keymap.set
15:  vim.keymap.set = function(_, lhs, rhs)
40:  vim.keymap.set = original_keymap_set
54:  local original_keymap_set = vim.keymap.set
57:  vim.keymap.set = function(_, lhs, rhs)
82:  vim.keymap.set = original_keymap_set
96:  local original_keymap_set = vim.keymap.set
98:  vim.keymap.set = function(_, lhs, rhs)
119:  vim.keymap.set = original_keymap_set
```

## ./pack/github/start/android-nvim-plugin/lua/tests/android/ui/hub/selection.lua

```
12:  local original_keymap_set = vim.keymap.set
15:  vim.keymap.set = function(_, lhs, rhs)
40:  vim.keymap.set = original_keymap_set
54:  local original_keymap_set = vim.keymap.set
59:  vim.keymap.set = function(_, lhs, rhs)
94:  vim.keymap.set = original_keymap_set
111:  local original_keymap_set = vim.keymap.set
113:  vim.keymap.set = function(_, lhs, rhs)
134:  vim.keymap.set = original_keymap_set
146:  local original_keymap_set = vim.keymap.set
149:  vim.keymap.set = function(_, lhs, rhs)
172:  vim.keymap.set = original_keymap_set
```

## ./pack/github/start/android-nvim-plugin/lua/tests/android/ui/input_test.lua

```
52:  vim.keymap.set = function() end
```

## ./pack/github/start/android-nvim-plugin/lua/tests/helpers/build_stream/vim.lua

```
10:    keymap_set = vim.keymap.set,
60:  vim.keymap.set = function(mode, lhs, rhs)
119:  vim.keymap.set = originals.keymap_set
```

## ./pack/github/start/codecompanion.nvim/lua/codecompanion/diff/ui.lua

```
163:  vim.keymap.set(mode, lhs, function()
```

## ./pack/github/start/codecompanion.nvim/lua/codecompanion/interactions/chat/acp/request_permission.lua

```
127:      vim.keymap.set("n", lhs, function()
145:  vim.keymap.set("n", "q", function()
```

## ./pack/github/start/codecompanion.nvim/lua/codecompanion/interactions/chat/helpers/approval_prompt.lua

```
100:    vim.keymap.set("n", choice.keymap, function()
```

## ./pack/github/start/codecompanion.nvim/lua/codecompanion/interactions/chat/keymaps/init.lua

```
642:      vim.keymap.set("n", key, function()
```

## ./pack/github/start/codecompanion.nvim/lua/codecompanion/interactions/shared/input.lua

```
203:            vim.keymap.set(mode, key, fn, { buffer = bufnr, desc = "[Input] " .. keymap.description })
```

## ./pack/github/start/codecompanion.nvim/lua/codecompanion/utils/keymaps.lua

```
108:            vim.keymap.set(mode, v, callback, key_opts)
111:          vim.keymap.set(mode, key, callback, key_opts)
```

## ./pack/github/start/codecompanion.nvim/lua/codecompanion/utils/ui.lua

```
110:  vim.keymap.set("n", "q", close, { buffer = bufnr })
```

## ./pack/github/start/codecompanion.nvim/tests/utils/test_context.lua

```
53:    vim.keymap.set("v", "<Leader>ts", "<cmd>TestVisualSelection<CR>", { buffer = _G.test_buffer })
```

## ./pack/github/start/Comment.nvim/lua/Comment/api.lua

```
75:---vim.keymap.set('n', '<C-_>', api.toggle.linewise.current)
78:---vim.keymap.set('n', '<C-\\>', api.toggle.blockwise.current)
81:----- Example: <leader>gc3j will comment 4 lines
82:---vim.keymap.set(
83:---    'n', '<leader>gc', api.call('toggle.linewise', 'g@'),
88:----- Example: <leader>gb3j will comment 4 lines
89:---vim.keymap.set(
90:---    'n', '<leader>gb', api.call('toggle.blockwise', 'g@'),
99:---vim.keymap.set('x', '<leader>c', function()
105:---vim.keymap.set('x', '<leader>b', function()
200:---vim.keymap.set(
201:---    'n', '<leader>c', api.locked('toggle.linewise.current')
207:---vim.keymap.set('x', '<leader>c', function()
236:---vim.keymap.set(
240:---vim.keymap.set(
```

## ./pack/github/start/Comment.nvim/lua/Comment/init.lua

```
80:---        line = '<leader>cc',
81:---        block = '<leader>bc',
84:---        line = '<leader>c',
85:---        block = '<leader>b',
95:        local K = vim.keymap.set
```

## ./pack/github/start/Comment.nvim/plugin/Comment.lua

```
1:local K = vim.keymap.set
73:---    vim.keymap.set('n', 'gcc', function()
80:---    vim.keymap.set('n', 'gc', '<Plug>(comment_toggle_linewise)')
83:---    vim.keymap.set('x', 'gc', '<Plug>(comment_toggle_linewise_visual)')
```

## ./pack/github/start/conform.nvim/lua/conform/health.lua

```
187:  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr, nowait = true })
188:  vim.keymap.set("n", "<C-c>", "<cmd>close<cr>", { buffer = bufnr })
```

## ./pack/github/start/diffview.nvim/lua/diffview/config.lua

```
132:      { "n", "<leader>e",   actions.focus_files,                    { desc = "Bring focus to the file panel" } },
133:      { "n", "<leader>b",   actions.toggle_files,                   { desc = "Toggle the file panel." } },
137:      { "n", "<leader>co",  actions.conflict_choose("ours"),        { desc = "Choose the OURS version of a conflict" } },
138:      { "n", "<leader>ct",  actions.conflict_choose("theirs"),      { desc = "Choose the THEIRS version of a conflict" } },
139:      { "n", "<leader>cb",  actions.conflict_choose("base"),        { desc = "Choose the BASE version of a conflict" } },
140:      { "n", "<leader>ca",  actions.conflict_choose("all"),         { desc = "Choose all the versions of a conflict" } },
142:      { "n", "<leader>cO",  actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
143:      { "n", "<leader>cT",  actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
144:      { "n", "<leader>cB",  actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
145:      { "n", "<leader>cA",  actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },
203:      { "n", "<leader>e",      actions.focus_files,                    { desc = "Bring focus to the file panel" } },
204:      { "n", "<leader>b",      actions.toggle_files,                   { desc = "Toggle the file panel" } },
209:      { "n", "<leader>cO",     actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
210:      { "n", "<leader>cT",     actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
211:      { "n", "<leader>cB",     actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
212:      { "n", "<leader>cA",     actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },
244:      { "n", "<leader>e",     actions.focus_files,                 { desc = "Bring focus to the file panel" } },
245:      { "n", "<leader>b",     actions.toggle_files,                { desc = "Toggle the file panel" } },
```

## ./pack/github/start/diffview.nvim/lua/diffview/scene/views/diff/file_panel.lua

```
81:    vim.keymap.set(mapping[1], mapping[2], mapping[3], opt)
```

## ./pack/github/start/diffview.nvim/lua/diffview/scene/views/file_history/file_history_panel.lua

```
150:    vim.keymap.set(mapping[1], mapping[2], mapping[3], opt)
```

## ./pack/github/start/diffview.nvim/lua/diffview/scene/views/file_history/option_panel.lua

```
168:    vim.keymap.set(mapping[1], mapping[2], mapping[3], opt)
174:      vim.keymap.set(
```

## ./pack/github/start/diffview.nvim/lua/diffview/ui/panels/help_panel.lua

```
105:    vim.keymap.set(mapping[1], mapping[2], mapping[3], map_opt)
108:  vim.keymap.set("n", "<cr>", function()
```

## ./pack/github/start/diffview.nvim/lua/diffview/vcs/file.lua

```
355:        vim.keymap.set(mapping[1], mapping[2], mapping[3], map_opt)
```

## ./pack/github/start/edgy.nvim/lua/edgy/actions.lua

```
17:        vim.keymap.set("n", key, function()
```

## ./pack/github/start/gitsigns.nvim/lua/gitsigns/actions/blame.lua

```
465:--- @param opts vim.keymap.set.Opts
469:  vim.keymap.set(mode, lhs, function()
546:  vim.keymap.set('n', '<CR>', function()
```

## ./pack/github/start/gitsigns.nvim/lua/gitsigns/actions/show_commit.lua

```
140:    vim.keymap.set('n', '<CR>', function()
144:    vim.keymap.set('n', '<C-o>', function()
152:    vim.keymap.set('n', '<C-i>', function()
```

## ./pack/github/start/gitsigns.nvim/lua/gitsigns/popup.lua

```
244:  vim.keymap.set('n', 'q', '<cmd>quit!<cr>', { silent = true, buffer = bufnr })
```

## ./pack/github/start/gitsigns.nvim/test/gs_helpers.lua

```
762:          vim.keymap.set(map[1], map[2], map[3], { buffer = bufnr })
```

## ./pack/github/start/harpoon/lua/harpoon/dev.lua

```
5:-- :nmap <leader>rr :lua require("harpoon.dev").reload()<CR>
```

## ./pack/github/start/harpoon/lua/harpoon/init.lua

```
33:        vim.keymap.set("n", "<C-V>", function()
41:        vim.keymap.set("n", "<C-x>", function()
49:        vim.keymap.set("n", "<C-t>", function()
```

## ./pack/github/start/leap.nvim/lua/leap/user.lua

```
57:   vim.keymap.set(modes, fwd_key, function() leap_repeat(false) end, {
62:   vim.keymap.set(modes, bwd_key, function() leap_repeat(true) end, {
178:            vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
```

## ./pack/github/start/leap.nvim/plugin/init.lua

```
1:local map = vim.keymap.set
```

## ./pack/github/start/LuaSnip/plugin/luasnip.lua

```
6:	vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc or "" })
```

## ./pack/github/start/LuaSnip/tests/integration/select_spec.lua

```
51:			vim.keymap.set({"x"}, "p", ls.select_keys, {silent = true})
68:			vim.keymap.set({"x"}, "p", ls.cut_keys, {silent = true})
85:			vim.keymap.set({"x"}, "y", [[<Esc><cmd>lua ls.pre_yank("d")<cr>gv"dy<cmd>lua ls.post_yank("d")<cr>]], {silent = true})
```

## ./pack/github/start/mason.nvim/lua/mason-core/ui/display.lua

```
371:                vim.keymap.set("n", keybind.key, function()
```

## ./pack/github/start/mini.nvim/lua/mini/ai.lua

```
553:---       vim.keymap.set(mode, to_lhs, rhs, { desc = keymap.desc })
2125:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/align.lua

```
1960:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/animate.lua

```
238:---       Example: a useful `nnoremap n nzvzz` mapping (consecutive application
525:--- A useful `nnoremap n nzvzz` mapping (consecutive application of |n|, |zv|, and |zz|)
```

## ./pack/github/start/mini.nvim/lua/mini/basics.lua

```
546:  -- Use `local map = vim.keymap.set` to copy lines as is. Or use it directly.
547:  local map = H.keymap_set
675:H.keymap_set = function(modes, lhs, rhs, opts)
761:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/bracketed.lua

```
162:---   local map = vim.keymap.set
1099:---       vim.keymap.set({ 'n', 'x' }, lhs, rhs, { expr = true })
1987:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/clue.lua

```
283:---     vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
286:---     vim.keymap.set('x', '<Leader>' .. suffix, rhs, { desc = desc })
1223:  if vim.fn.maparg('@', 'n') == '' then vim.keymap.set('n', '@', exec_register_macro, macro_keymap_opts) end
1226:  if vim.fn.maparg('Q', 'n') == '' then vim.keymap.set('n', 'Q', exec_latest_macro, macro_keymap_opts) end
1375:  vim.keymap.set(trigger.mode, lhs, rhs, opts)
1982:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/cmdline.lua

```
562:      vim.keymap.set('c', dir, rhs, { expr = true, desc = desc })
```

## ./pack/github/start/mini.nvim/lua/mini/colors.lua

```
895:  local m = function(action, rhs) vim.keymap.set('n', maps[action], rhs, { desc = action, buffer = buf_id }) end
```

## ./pack/github/start/mini.nvim/lua/mini/comment.lua

```
580:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/completion.lua

```
178:---     vim.keymap.set('i', lhs, rhs, { expr = true })
195:---   vim.keymap.set('i', '<CR>', 'v:lua.cr_action()', { expr = true })
2000:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/diff.lua

```
836:---   vim.keymap.set('n', 'ghy', rhs, { expr = true, remap = true })
1892:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/files.lua

```
469:---       vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id })
495:---     vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
534:---       vim.keymap.set('n', 'g~', set_cwd,   { buffer = b, desc = 'Set cwd' })
535:---       vim.keymap.set('n', 'gX', ui_open,   { buffer = b, desc = 'OS open' })
536:---       vim.keymap.set('n', 'gy', yank_path, { buffer = b, desc = 'Yank path' })
1988:  vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = buf_id, desc = 'Close this window' })
3075:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/git.lua

```
130:---   vim.keymap.set({ 'n', 'x' }, '<Leader>gs', rhs, { desc = 'Show at cursor' })
```

## ./pack/github/start/mini.nvim/lua/mini/indentscope.lua

```
1144:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/jump.lua

```
155:---   vim.keymap.set({ 'n', 'x', 'o' }, '<Esc>', jump_stop, opts)
601:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/jump2d.lua

```
632:---   vim.keymap.set(
794:    local revert_cr = function() vim.keymap.set('n', '<CR>', '<CR>', { buffer = true }) end
1199:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/keymap.lua

```
296:---@param mode string|table Same as for |vim.keymap.set()|.
297:---@param lhs string Same as for |vim.keymap.set()|.
311:---@param opts table|nil Same as for |vim.keymap.set()|.
376:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/map.lua

```
65:---       vim.keymap.set('n', '<CR>', rhs, { buffer = true })
149:---   vim.keymap.set('n', '<Leader>mc', MiniMap.close)
150:---   vim.keymap.set('n', '<Leader>mf', MiniMap.toggle_focus)
151:---   vim.keymap.set('n', '<Leader>mo', MiniMap.open)
152:---   vim.keymap.set('n', '<Leader>mr', MiniMap.refresh)
153:---   vim.keymap.set('n', '<Leader>ms', MiniMap.toggle_side)
154:---   vim.keymap.set('n', '<Leader>mt', MiniMap.toggle)
749:---     vim.keymap.set('n', key, rhs)
1412:  vim.keymap.set('n', '<CR>', '<Cmd>lua MiniMap.toggle_focus(false)<CR>', { buffer = buf_id })
1413:  vim.keymap.set('n', '<Esc>', '<Cmd>lua MiniMap.toggle_focus(true)<CR>', { buffer = buf_id })
```

## ./pack/github/start/mini.nvim/lua/mini/misc.lua

```
799:--- locally modifying 'comments' option (by prepending `n:<leader>`). Does
```

## ./pack/github/start/mini.nvim/lua/mini/move.lua

```
461:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/operators.lua

```
724:    vim.keymap.set(mode, 'gX', rhs, { desc = keymap.desc })
958:  vim.keymap.set('n', lhs, H.exchange_stop, { desc = 'Stop exchange' })
1279:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/pairs.lua

```
34:---       `inoremap <buffer> <*> <*>` (this maps `<*>` key to do the same it
265:---   vim.keymap.set('i', 'X', 'X', { buffer = true })
358:---     vim.keymap.set('i', lhs, rhs, { expr = true, replace_keycodes = false })
641:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/snippets.lua

```
435:---   vim.keymap.set('i', '<C-g><C-j>', rhs, { desc = 'Expand all' })
461:---   vim.keymap.set('i', '<Tab>', expand_or_jump, { expr = true })
462:---   vim.keymap.set('i', '<S-Tab>', jump_prev)
527:---   vim.keymap.set({ 'i', 's' }, '<C-l>', jump_next)
528:---   vim.keymap.set({ 'i', 's' }, '<C-h>', jump_prev)
1613:    vim.keymap.set('i', lhs, rhs, { desc = desc })
2224:    vim.keymap.set('i', lhs, '<Cmd>lua MiniSnippets.session.' .. call .. '<CR>', { desc = desc })
```

## ./pack/github/start/mini.nvim/lua/mini/splitjoin.lua

```
1117:  vim.keymap.set(mode, lhs, rhs, opts)
```

## ./pack/github/start/mini.nvim/lua/mini/starter.lua

```
1383:    vim.keymap.set('n', key, ('<Cmd>lua %s<CR>'):format(cmd), { buffer = buf_id, nowait = true, silent = true })
```

## ./pack/github/start/mini.nvim/lua/mini/surround.lua

```
677:---   vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
680:---   vim.keymap.set('n', 'yss', 'ys_', { remap = true })
908:---   vim.keymap.set('n', 'sn', '<Cmd>lua MiniSurround.update_n_lines()<CR>')
2272:  vim.keymap.set(mode, lhs, rhs, opts)
2274:  if no_global_s_mapping and lhs:find('^s.') ~= nil then vim.keymap.set(mode, 's', '<Nop>') end
```

## ./pack/github/start/mini.nvim/lua/mini/test.lua

```
2162:  vim.keymap.set('n', '<Esc>', rhs, { buffer = buf_id, desc = 'Stop execution or close window' })
2163:  vim.keymap.set('n', 'q', rhs, { buffer = buf_id, desc = 'Stop execution or close window' })
```

## ./pack/github/start/mini.nvim/lua/mini/visits.lua

```
243:---     vim.keymap.set('n', lhs, make_select_path(...), { desc = desc })
271:---     vim.keymap.set('n', '<Leader>' .. keys, rhs, { desc = desc })
289:---     vim.keymap.set('n', '<Leader>' .. keys, rhs, { desc = desc })
304:---     vim.keymap.set('n', lhs, rhs, { desc = desc })
325:---     vim.keymap.set('n', '<Leader>' .. keys, rhs, { desc = desc })
```

## ./pack/github/start/mini.nvim/tests/test_ai.lua

```
2304:    vim.keymap.set('n', 'gr', _G.MiniOperators.replace, { expr = true })
```

## ./pack/github/start/mini.nvim/tests/test_basics.lua

```
265:  child.lua([[vim.keymap.set('n', '<C-l>', function() end, { desc = 'Test' })]])
```

## ./pack/github/start/mini.nvim/tests/test_clue.lua

```
50:    [[vim.keymap.set('%s', '%s', function() _G['test_map_%s_%s'] = _G['test_map_%s_%s'] + 1 end, %s)]],
148:    vim.keymap.set('n', 'gc', _G.comment_operator, { expr = true, replace_keycodes = false })
149:    vim.keymap.set('n', 'gcc', _G.comment_line, { expr = true, replace_keycodes = false })
366:  child.cmd([[au LspAttach * lua vim.keymap.set('n', '<Space>a', ':echo 1<CR>', { buffer = true })]])
795:  child.lua([[vim.keymap.set('n', '<Space>a', function() _G.been_here = true end)]])
2226:    vim.keymap.set('n', '<Space>f', _G.add_hl, { desc = 'Add hl' })]])
2516:    vim.keymap.set('n', 'ge', _G.track_register)
2522:    vim.keymap.set('n', 'gE', _G.track_register_expr, { expr = true })
2535:    vim.keymap.set('n', 'gd', function() return 'P' end, { expr = true })
2674:    vim.keymap.set('x', 'ge', _G.track_register)
2680:    vim.keymap.set('x', 'gE', _G.track_register_expr, { expr = true })
3356:  child.cmd('nnoremap <Leader>a <Cmd>lua _G.n = (_G.n or 0) + 1<CR>')
3357:  child.cmd('nnoremap <F3>b <Cmd>lua _G.m = (_G.m or 0) + 1<CR>')
```

## ./pack/github/start/mini.nvim/tests/test_cmdline.lua

```
447:  child.cmd('nnoremap <C-x> :sort<CR>')
886:  child.cmd('nnoremap <C-x> :ehco<CR>')
1280:  child.cmd('nnoremap <C-x> :2,3sort<CR>')
1285:  child.cmd('nnoremap <C-y> :3,4')
```

## ./pack/github/start/mini.nvim/tests/test_completion.lua

```
2502:    vim.keymap.set('i', '<CR>', 'v:lua._G.cr_action()', { expr = true })
2513:  child.cmd('inoremap ( (abc)<Left><Left><Left>')
2828:  child.cmd('inoremap ( (abc)<Left><Left><Left>')
```

## ./pack/github/start/mini.nvim/tests/test_diff.lua

```
1917:    vim.keymap.set('n', 'ghy', rhs, { expr = true, remap = true })
```

## ./pack/github/start/mini.nvim/tests/test_files.lua

```
1104:      vim.keymap.set('i', '<CR>', function() close(vim.fn.getline('.')) end, { buffer = buf_id })
1105:      vim.keymap.set('i', '<Esc>', function() close() end, { buffer = buf_id })
1931:  child.lua([[vim.keymap.set('n', 'g.', '<Cmd>echo 1<CR>', { buffer = vim.api.nvim_get_current_buf() })]])
5498:        callback = function(args) vim.keymap.set('n', 'W', rhs, { buffer = args.data.buf_id }) end,
```

## ./pack/github/start/mini.nvim/tests/test_keymap.lua

```
1379:  child.cmd('nnoremap ll <Cmd>lua table.insert(_G.log, "custom ll")<CR>')
```

## ./pack/github/start/mini.nvim/tests/test_map.lua

```
1076:      vim.keymap.set(
```

## ./pack/github/start/mini.nvim/tests/test_notify.lua

```
590:    vim.keymap.set('o', '<C-a>', a, { expr = true })
596:    vim.keymap.set('n', '<C-r>', r, { expr = true })
```

## ./pack/github/start/mini.nvim/tests/test_operators.lua

```
161:  child.lua('vim.keymap.set({ "n", "x" }, "gx", function() _G.n = _G.n + 5 end)')
167:  child.lua('vim.keymap.set({ "n", "x" }, "gx", function() _G.n = _G.n + 5 end, { desc = "URI under cursor" })')
168:  child.lua('vim.keymap.set({ "n", "x" }, "gX", function() _G.n = _G.n + 10 end)')
454:  child.lua([[vim.keymap.set('o', 'ia', function() vim.cmd('normal! \22j$') end)]])
455:  child.lua([[vim.keymap.set('o', 'ib', function() vim.cmd('normal! \22j4l') end)]])
519:    child.lua([[vim.keymap.set('o', 'iL', function() vim.cmd('normal! \22jll') end)]])
615:  child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j3l') end)]])
733:  child.lua([[vim.keymap.set('o', 'io', function() vim.cmd('normal! \22') end)]])
734:  child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j') end)]])
735:  child.lua([[vim.keymap.set('o', 'iE', function() vim.cmd('normal! \22jj') end)]])
736:  child.lua([[vim.keymap.set('o', 'il', function() vim.cmd('normal! \22jl') end)]])
764:  child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j') end)]])
921:    child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j') end)]])
940:  child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j') end)]])
1229:  child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j') end)]])
1328:  child.lua([[vim.keymap.set('o', 'ia', function() vim.cmd('normal! \22jl') end)]])
1329:  child.lua([[vim.keymap.set('o', 'ib', function() vim.cmd('normal! \22jh') end)]])
1330:  child.lua([[vim.keymap.set('o', 'ic', function() vim.cmd('normal! \22kl') end)]])
1331:  child.lua([[vim.keymap.set('o', 'id', function() vim.cmd('normal! \22kh') end)]])
1357:  child.lua([[vim.keymap.set('o', 'ia', function() vim.cmd('normal! \22j' .. vim.v.count1 .. 'l') end)]])
1487:    child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j') end)]])
1636:  child.lua([[vim.keymap.set('o', 'ia', _G.block_object('jl'))]])
1637:  child.lua([[vim.keymap.set('o', 'ib', _G.block_object('jh'))]])
1638:  child.lua([[vim.keymap.set('o', 'ic', _G.block_object('kl'))]])
1639:  child.lua([[vim.keymap.set('o', 'id', _G.block_object('kh'))]])
1769:  child.lua([[vim.keymap.set('o', 'io', function() vim.cmd('normal! \22') end)]])
1770:  child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j') end)]])
1782:  child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j') end)]])
1912:    child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j') end)]])
2141:  child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j') end)]])
2245:  child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22j') end)]])
2246:  child.lua([[vim.keymap.set('o', 'il', function() vim.cmd('normal! \22jl') end)]])
2315:    child.lua([[vim.keymap.set('o', 'iE', function() vim.cmd('normal! \22jj') end)]])
2415:  child.lua([[vim.keymap.set('o', 'ie', function() vim.cmd('normal! \22jll') end)]])
```

## ./pack/github/start/mini.nvim/tests/test_pairs.lua

```
554:  child.cmd('inoremap <CR> <Cmd>echo "Hello"<CR>')
725:  child.cmd('inoremap <C-j> <Cmd>call nvim_feedkeys("((", "", v:true)<CR>')
1028:      vim.keymap.set('i', lhs, rhs, { expr = true, replace_keycodes = false })
1227:  child.cmd('inoremap <C-j> <Cmd>call nvim_feedkeys("(\\r(\\r", "", v:true)<CR>')
```

## ./pack/github/start/mini.nvim/tests/test_snippets.lua

```
5281:    vim.keymap.set('i', '<C-g><C-j>', rhs, { desc = 'Expand all' })
5342:    vim.keymap.set('i', '<Tab>', expand_or_jump, { expr = true })
5343:    vim.keymap.set('i', '<S-Tab>', jump_prev)
5381:    vim.keymap.set({ 'i', 's' }, '<C-l>', jump_next)
5382:    vim.keymap.set({ 'i', 's' }, '<C-h>', jump_prev)
```

## ./pack/github/start/mini.nvim/tests/test_starter.lua

```
217:      child.cmd([[nnoremap <C-\> <Cmd>lua _G.been_inside_ctrlslash = true<CR>]])
```

## ./pack/github/start/mini.nvim/tests/test_surround.lua

```
271:    pre_case = function() child.lua('vim.keymap.set("n", "sn", "<Cmd>lua MiniSurround.update_n_lines()<CR>")') end,
```

## ./pack/github/start/neogit/lua/neogit.lua

```
181:--   vim.keymap.set('n', '<leader>gcc', neogit.action('commit', 'commit', { '--verbose', '--all' }))
```

## ./pack/github/start/neogit/lua/neogit/lib/buffer.lua

```
769:      vim.keymap.set("n", key, fn, opts)
788:          vim.keymap.set(mode, k, fn, opts)
```

## ./pack/github/start/neogit/lua/neogit/lib/jump.lua

```
199:  vim.keymap.set("n", "q", function()
```

## ./pack/github/start/nvim-cmp/lua/cmp/utils/api_spec.lua

```
18:      keymap.set_map(0, 'c', '<Plug>(cmp-spec-spy)', function()
37:      keymap.set_map(0, 'c', '<Plug>(cmp-spec-spy)', function()
56:      keymap.set_map(0, 'c', '<Plug>(cmp-spec-spy)', function()
```

## ./pack/github/start/nvim-cmp/lua/cmp/utils/keymap.lua

```
127:  if existing.desc == 'cmp.utils.keymap.set_map' then
133:  keymap.set_map(bufnr, mode, lhs, function()
153:      keymap.set_map(bufnr, mode, fallback_lhs, function()
191:    keymap.set_map(bufnr, mode, recursive, lhs, {
261:keymap.set_map = function(bufnr, mode, lhs, rhs, opts)
266:  opts.desc = 'cmp.utils.keymap.set_map'
```

## ./pack/github/start/nvim-dap-ui/lua/dapui/elements/console.lua

```
23:      vim.keymap.set("n", "G", function()
```

## ./pack/github/start/nvim-dap/lua/dap/repl.lua

```
53:  vim.keymap.set("n", "]]", function()
63:  vim.keymap.set("n", "[[", function()
84:    vim.keymap.set('n', 'G', function()
```

## ./pack/github/start/nvim-lspconfig/lsp/copilot.lua

```
27:---       vim.keymap.set(
33:---       vim.keymap.set(
```

## ./pack/github/start/nvim-lspconfig/lsp/gitlab_duo.lua

```
32:---       vim.keymap.set('i', '<Tab>', function()
39:---       vim.keymap.set('i', '<M-[>', function() vim.lsp.inline_completion.select({ count = -1 }) end,
43:---       vim.keymap.set('i', '<M-]>', function() vim.lsp.inline_completion.select({ count = 1 }) end,
```

## ./pack/github/start/nvim-lspconfig/lua/lspconfig/health.lua

```
341:  vim.cmd [[nnoremap <buffer> q <c-w>q]]
```

## ./pack/github/start/nvim-tree.lua/lua/nvim-tree/help.lua

```
253:    vim.keymap.set("n", k, v.fn, {
```

## ./pack/github/start/nvim-tree.lua/lua/nvim-tree/keymap.lua

```
60:  vim.keymap.set("n",          "<C-]>",          api.tree.change_root_to_node,       opts("CD"))
61:  vim.keymap.set("n",          "<C-e>",          api.node.open.replace_tree_buffer,  opts("Open: In Place"))
62:  vim.keymap.set("n",          "<C-k>",          api.node.show_info_popup,           opts("Info"))
63:  vim.keymap.set("n",          "<C-r>",          api.fs.rename_sub,                  opts("Rename: Omit Filename"))
64:  vim.keymap.set("n",          "<C-t>",          api.node.open.tab,                  opts("Open: New Tab"))
65:  vim.keymap.set("n",          "<C-v>",          api.node.open.vertical,             opts("Open: Vertical Split"))
66:  vim.keymap.set("n",          "<C-x>",          api.node.open.horizontal,           opts("Open: Horizontal Split"))
67:  vim.keymap.set("n",          "<BS>",           api.node.navigate.parent_close,     opts("Close Directory"))
68:  vim.keymap.set("n",          "<CR>",           api.node.open.edit,                 opts("Open"))
69:  vim.keymap.set({ "n", "x" }, "<Del>",          api.fs.remove,                      opts("Delete"))
70:  vim.keymap.set("n",          "<Tab>",          api.node.open.preview,              opts("Open Preview"))
71:  vim.keymap.set("n",          ">",              api.node.navigate.sibling.next,     opts("Next Sibling"))
72:  vim.keymap.set("n",          "<",              api.node.navigate.sibling.prev,     opts("Previous Sibling"))
73:  vim.keymap.set("n",          ".",              api.node.run.cmd,                   opts("Run Command"))
74:  vim.keymap.set("n",          "-",              api.tree.change_root_to_parent,     opts("Up"))
75:  vim.keymap.set("n",          "a",              api.fs.create,                      opts("Create File Or Directory"))
76:  vim.keymap.set("n",          "bd",             api.marks.bulk.delete,              opts("Delete Bookmarked"))
77:  vim.keymap.set("n",          "bt",             api.marks.bulk.trash,               opts("Trash Bookmarked"))
78:  vim.keymap.set("n",          "bmv",            api.marks.bulk.move,                opts("Move Bookmarked"))
79:  vim.keymap.set("n",          "B",              api.filter.no_buffer.toggle,        opts("Toggle Filter: No Buffer"))
80:  vim.keymap.set({ "n", "x" }, "c",              api.fs.copy.node,                   opts("Copy"))
81:  vim.keymap.set("n",          "C",              api.filter.git.clean.toggle,        opts("Toggle Filter: Git Clean"))
82:  vim.keymap.set("n",          "[c",             api.node.navigate.git.prev,         opts("Prev Git"))
83:  vim.keymap.set("n",          "]c",             api.node.navigate.git.next,         opts("Next Git"))
84:  vim.keymap.set({ "n", "x" }, "d",              api.fs.remove,                      opts("Delete"))
85:  vim.keymap.set({ "n", "x" }, "D",              api.fs.trash,                       opts("Trash"))
86:  vim.keymap.set("n",          "E",              api.tree.expand_all,                opts("Expand All"))
87:  vim.keymap.set("n",          "e",              api.fs.rename_basename,             opts("Rename: Basename"))
88:  vim.keymap.set("n",          "]e",             api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
89:  vim.keymap.set("n",          "[e",             api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
90:  vim.keymap.set("n",          "F",              api.filter.live.clear,              opts("Live Filter: Clear"))
91:  vim.keymap.set("n",          "f",              api.filter.live.start,              opts("Live Filter: Start"))
92:  vim.keymap.set("n",          "g?",             api.tree.toggle_help,               opts("Help"))
93:  vim.keymap.set("n",          "gy",             api.fs.copy.absolute_path,          opts("Copy Absolute Path"))
94:  vim.keymap.set("n",          "ge",             api.fs.copy.basename,               opts("Copy Basename"))
95:  vim.keymap.set("n",          "H",              api.filter.dotfiles.toggle,         opts("Toggle Filter: Dotfiles"))
96:  vim.keymap.set("n",          "I",              api.filter.git.ignored.toggle,      opts("Toggle Filter: Git Ignored"))
97:  vim.keymap.set("n",          "J",              api.node.navigate.sibling.last,     opts("Last Sibling"))
98:  vim.keymap.set("n",          "K",              api.node.navigate.sibling.first,    opts("First Sibling"))
99:  vim.keymap.set("n",          "L",              api.node.open.toggle_group_empty,   opts("Toggle Group Empty"))
100:  vim.keymap.set("n",          "M",              api.filter.no_bookmark.toggle,      opts("Toggle Filter: No Bookmark"))
101:  vim.keymap.set({ "n", "x" }, "m",              api.marks.toggle,                   opts("Toggle Bookmark"))
102:  vim.keymap.set("n",          "o",              api.node.open.edit,                 opts("Open"))
103:  vim.keymap.set("n",          "O",              api.node.open.no_window_picker,     opts("Open: No Window Picker"))
104:  vim.keymap.set("n",          "p",              api.fs.paste,                       opts("Paste"))
105:  vim.keymap.set("n",          "P",              api.node.navigate.parent,           opts("Parent Directory"))
106:  vim.keymap.set("n",          "q",              api.tree.close,                     opts("Close"))
107:  vim.keymap.set("n",          "r",              api.fs.rename,                      opts("Rename"))
108:  vim.keymap.set("n",          "R",              api.tree.reload,                    opts("Refresh"))
109:  vim.keymap.set("n",          "s",              api.node.run.system,                opts("Run System"))
110:  vim.keymap.set("n",          "S",              api.tree.search_node,               opts("Search"))
111:  vim.keymap.set("n",          "u",              api.fs.rename_full,                 opts("Rename: Full Path"))
112:  vim.keymap.set("n",          "U",              api.filter.custom.toggle,           opts("Toggle Filter: Custom"))
113:  vim.keymap.set("n",          "W",              api.tree.collapse_all,              opts("Collapse All"))
114:  vim.keymap.set({ "n", "x" }, "x",              api.fs.cut,                         opts("Cut"))
115:  vim.keymap.set("n",          "y",              api.fs.copy.filename,               opts("Copy Name"))
116:  vim.keymap.set("n",          "Y",              api.fs.copy.relative_path,          opts("Copy Relative Path"))
117:  vim.keymap.set("n",          "<2-LeftMouse>",  api.node.open.edit,                 opts("Open"))
118:  vim.keymap.set("n",          "<2-RightMouse>", api.tree.change_root_to_node,       opts("CD"))
```

## ./pack/github/start/oil.nvim/lua/oil/adapters/ssh.lua

```
399:    vim.keymap.set("n", "gf", M.goto_file, { buffer = bufnr })
```

## ./pack/github/start/oil.nvim/lua/oil/config.lua

```
54:  -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
```

## ./pack/github/start/oil.nvim/lua/oil/keymap_util.lua

```
42:    -- remove all the keys that we can't pass as options to `vim.keymap.set`
71:      vim.keymap.set(mode or "", k, rhs, vim.tbl_extend("keep", { buffer = bufnr }, opts))
132:  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = bufnr })
133:  vim.keymap.set("n", "<c-c>", "<cmd>close<CR>", { buffer = bufnr })
```

## ./pack/github/start/oil.nvim/lua/oil/mutator/confirmation.lua

```
178:    vim.keymap.set("n", cancel_key, function()
186:    vim.keymap.set("n", confirm_key, function()
```

## ./pack/github/start/oil.nvim/lua/oil/mutator/progress.lua

```
97:  vim.keymap.set("n", "c", cancel, { buffer = self.bufnr, nowait = true })
98:  vim.keymap.set("n", "C", cancel, { buffer = self.bufnr, nowait = true })
99:  vim.keymap.set("n", "m", minimize, { buffer = self.bufnr, nowait = true })
100:  vim.keymap.set("n", "M", minimize, { buffer = self.bufnr, nowait = true })
```

## ./pack/github/start/oil.nvim/tests/manual_progress.lua

```
26:vim.keymap.set("n", "R", function()
```

## ./pack/github/start/plenary.nvim/plugin/plenary.vim

```
9:nnoremap <Plug>PlenaryTestFile :lua require('plenary.test_harness').test_file(vim.fn.expand("%:p"))<CR>
```

## ./pack/github/start/plenary.nvim/tests/minimal_init.vim

```
5:nnoremap ,,x :luafile %<CR>
```

## ./pack/github/start/telescope.nvim/lua/telescope/mappings.lua

```
273:      vim.keymap.set(
289:  vim.keymap.set(mode, key_bind, function()
```

## ./pack/github/start/telescope.nvim/plugin/telescope.lua

```
99:vim.keymap.set(
```

## ./pack/github/start/undotree/autoload/undotree.vim

```
342:        silent exec 'nnoremap '.map_options.'<plug>Undotree'.i[0]
```

## ./pack/github/start/vim-floaterm/plugin/floaterm.vim

```
67:    execute printf('nnoremap <silent> %s :%s<CR>', a:mapvar, a:command)
```

## ./plugin/floatterminal.lua

```
42:--vim.keymap.set('n', '<leader>;', function()
```

