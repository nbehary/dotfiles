# Chezmoi Migration Plan

## Current State

The repo has four active branches representing different machine configurations:

| Branch | Machine | Notable configs |
|---|---|---|
| `main` | Linux desktop | hyprland, dk/sxhkd, picom, rofi, alacritty, ghostty, zellij, wezterm |
| `my_mac_stuff_2` | Work Mac | yabai/skhd/sketchybar, yazi, Android dev tooling (bin/, scripts/) |
| `android_neovim` | Standalone/shareable | Android-focused nvim subset |
| `my_work_mac` | Older Mac branch | (superseded by my_mac_stuff_2) |

The `.zshrc` is already partially machine-aware (OS detection, conditional PATH setup) — a good sign that the content is ready for templating.

---

## Target State

A single chezmoi-managed repo on one branch (`main`). Machine differences are handled via chezmoi data variables and templates rather than git branches. The `android_neovim` config becomes a separate standalone repo (see below).

---

## Machine Data Schema

During `chezmoi init`, a `.chezmoi.toml.tmpl` template prompts for (or detects) these data values:

```toml
[data]
  machine = "desktop"       # or "work-mac"
  androidDev = true         # enables Android tooling in nvim + bin/scripts
```

`machine` drives OS-level tool selection. `androidDev` is orthogonal — you might want Android dev on any machine.

Chezmoi also provides built-in `.chezmoi.os` (`linux`/`darwin`) and `.chezmoi.hostname` that can supplement or replace `machine` if detection can be made reliable enough.

---

## New Repo Layout

```
~/.local/share/chezmoi/         ← chezmoi source directory (git repo)
├── .chezmoi.toml.tmpl          ← prompts/detects machine data on init
├── dot_zshrc.tmpl              ← templated zshrc
├── dot_tmux.conf               ← shared, no template needed
├── dot_config/
│   ├── nvim/                   ← shared nvim base (exact copy, no template)
│   │   └── lua/android/        ← conditionally installed via chezmoi (see below)
│   ├── yazi/                   ← mac-only (conditional)
│   ├── ghostty/                ← mac-only terminal
│   ├── alacritty/              ← desktop terminal
│   ├── zellij/                 ← desktop
│   ├── hypr/                   ← desktop WM
│   ├── dk/                     ← desktop WM
│   ├── picom/                  ← desktop compositor
│   ├── rofi/                   ← desktop launcher
│   ├── yabai/                  ← mac WM
│   ├── skhd/                   ← mac hotkeys
│   └── sketchybar/             ← mac bar
├── bin/                        ← Android scripts (conditional)
└── scripts/                    ← setup scripts (conditional)
```

---

## Handling Machine-Specific Files

Chezmoi has three mechanisms; use the right one per case:

### 1. Templates (`.tmpl` suffix) — for files that are mostly shared with small differences

Best for `.zshrc`, which already has conditional blocks. The template just replaces the runtime `uname` checks with chezmoi data variables that are resolved once at apply time:

```
{{ if eq .chezmoi.os "darwin" -}}
# mac-specific content
{{ end -}}
```

Files to template: `.zshrc` (already has the structure for this).

### 2. Conditional `dot_config` subdirectories — for entire tool configs that only exist on one machine

Use chezmoi's `.chezmoiignore` with template syntax to skip irrelevant dirs entirely:

```
# .chezmoiignore
{{ if ne .chezmoi.os "darwin" }}
.config/yabai
.config/skhd
.config/sketchybar
.config/yazi
.config/ghostty
{{ end }}
{{ if ne .chezmoi.os "linux" }}
.config/hypr
.config/dk
.config/picom
.config/rofi
.config/zellij
.config/alacritty
{{ end }}
{{ if not .androidDev }}
bin
scripts
.config/nvim/lua/android
.config/nvim/after/plugin/android_project_view.lua
.config/nvim/lua/jdtls_start.lua
.config/nvim/kotlinDSLClassPathFinder.gradle
.config/nvim/projectClassPathFinder.gradle
{{ end }}
```

This keeps the source repo complete while each machine only materializes what it needs.

### 3. `run_onchange_` scripts — for post-apply setup that differs by machine

Example: `run_onchange_install-mac-deps.sh.tmpl` that runs `brew install` on macOS, or `run_onchange_install-arch-deps.sh.tmpl` for pacman. These only re-run when their content changes (chezmoi hashes them).

---

## The `android_neovim` Branch

This branch is meant to be a standalone, shareable nvim config for Android development. It should **not** be folded into the chezmoi repo — it would lose its standalone character. Recommended approach:

1. Extract `android_neovim` into its own repo (e.g., `github.com/nbehary/android-nvim` or similar).
2. In the chezmoi repo, when `androidDev = true`, use a chezmoi **external** to pull that repo's contents into `.config/nvim/lua/android/`:
   ```toml
   # dot_config/nvim/lua/android/.chezmoidata.toml
   # or in .chezmoidata.toml at root:
   [".config/nvim/lua/android"]
     type = "git-repo"
     url = "https://github.com/YOU/android-nvim.git"
     refreshPeriod = "168h"
   ```
3. Keep `android_neovim` as a git remote branch for now until the standalone repo is set up.

Alternatively, if standalone sharing is low priority, just keep the Android files in the chezmoi repo gated behind `androidDev = true` and leave `android_neovim` as an archived branch.

---

## Migration Steps

### Phase 0: Audit & cleanup (before touching chezmoi)
- [ ] Decide whether `android_neovim` becomes a standalone repo or stays inline
- [ ] Audit `main` branch for cruft: it currently has both Linux WM tools (hyprland, dk) AND macOS WM tools (yabai, sketchybar, skhd, borders) — determine which are actually in use and which are dead
- [ ] Decide fate of `my_work_mac` and `wezterm` branches (likely archive/delete)
- [ ] Check `.gitmodules` — submodules need special handling in chezmoi (either chezmoi externals or include as-is)

### Phase 1: Set up chezmoi on the work Mac (primary machine)
- [ ] `brew install chezmoi`
- [ ] `chezmoi init` — creates `~/.local/share/chezmoi`
- [ ] Create `.chezmoi.toml.tmpl` with machine data prompts
- [ ] `chezmoi add ~/.zshrc` — import current live file
- [ ] `chezmoi add ~/.tmux.conf`
- [ ] `chezmoi add ~/.config/nvim` (the full nvim dir)
- [ ] Add remaining mac configs: yabai, skhd, sketchybar, yazi, ghostty

### Phase 2: Templatize `.zshrc`
- [ ] Convert the existing OS-detection blocks to chezmoi template syntax
- [ ] Run `chezmoi apply` and verify the rendered file matches the original live file
- [ ] Add the Linux-only blocks from `main`'s `.zshrc`

### Phase 3: Add desktop configs from `main`
- [ ] Checkout `main` locally, copy Linux-only configs into the chezmoi source
- [ ] Add to `.chezmoiignore` so they're skipped on macOS
- [ ] Commit and push the chezmoi source repo

### Phase 4: Bootstrap the desktop
- [ ] Install chezmoi on the desktop
- [ ] `chezmoi init --apply <repo-url>` — clones source and applies, prompting for machine data
- [ ] Verify all Linux configs land correctly

### Phase 5: Cut over git management
- [ ] Archive (or delete) the old `my_mac_stuff_2`, `my_work_mac`, `main`, `wezterm`, `laptop_stuff` branches
- [ ] The chezmoi source repo is now the single source of truth
- [ ] The old dotfiles repo can be archived or deleted on GitHub

### Phase 6: Ongoing workflow
After migration, the daily workflow is:
```sh
chezmoi edit ~/.zshrc        # opens source file in $EDITOR
chezmoi apply                # applies changes to live files
chezmoi diff                 # see what would change before applying
chezmoi cd && git push       # commit and push source changes
```

On a new machine: `chezmoi init --apply <repo-url>` and answer the prompts.

---

## Key Decisions to Make Before Starting

1. **`android_neovim`: standalone repo or inline?** Inline is simpler to migrate; standalone is better long-term if you want to share it.
2. **Machine data: `machine` string or just `chezmoi.os`?** Using `chezmoi.os` is zero-config (auto-detected) but can't distinguish two Macs with different roles. A `machine` data key is more explicit but requires a prompt on init.
3. **The nvim `pack/` directory**: it contains git submodules for plugins. Chezmoi can manage these, but it's worth considering switching to lazy.nvim (plugin manager) which handles its own installs — that would let you drop the entire `pack/` subtree from the dotfiles repo.
4. **The `.config/nvim/com/` and `.config/nvim/org/` directories**: these contain compiled Java `.class` files checked into git, which is unusual. These are probably jdtls workspace artifacts and should be gitignored rather than managed by chezmoi.

---

## References

- [chezmoi docs](https://www.chezmoi.io/user-guide/setup/)
- [chezmoi template reference](https://www.chezmoi.io/reference/templates/)
- [chezmoi externals](https://www.chezmoi.io/reference/special-files-and-directories/chezmoidata-toml/)
- [`.chezmoiignore` docs](https://www.chezmoi.io/reference/special-files-and-directories/chezmoiignore/)
