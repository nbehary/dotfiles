# Chezmoi Migration Status

## What was built

| File | Purpose |
|---|---|
| `.chezmoi.toml.tmpl` | Prompts for `machine` + `androidDev` on `chezmoi init` |
| `.chezmoiignore` | Conditionally skips dirs per machine/OS |
| `dot_zshrc.tmpl` | Unified zinit+p10k zshrc with template variables |
| `dot_config/hypr/hyprland.conf.tmpl` | Hyprland config with hardcoded `/home/maxgreene/` replaced by `{{ .chezmoi.homeDir }}` |
| `dot_tmux.conf` | Shared tmux config |
| `dot_wezterm.lua` | Linux-only (ignored on darwin via `.chezmoiignore`) |

## Machine conditions (`.chezmoiignore`)

| Condition | Excluded configs |
|---|---|
| Non-Mac | yabai, skhd, sketchybar, yazi, borders |
| Non-Linux | alacritty, dk, rofi, zellij, ghostty, wezterm |
| Non-desktop | picom |
| Non-laptop | hypr |
| `androidDev=false` | `bin/`, nvim android modules |

## Machine data schema

```toml
[data]
  machine = "work-mac"   # or "desktop" or "laptop"
  androidDev = true      # or false
```

## Bootstrap a new machine

```sh
chezmoi init --apply https://github.com/nbehary/dotfiles --branch chezmoi
# Prompts: machine type, androidDev bool
```

## Remaining steps

- [ ] Bootstrap work Mac (`machine=work-mac`, `androidDev=true`) and verify configs apply correctly
- [ ] Bootstrap desktop (`machine=desktop`, `androidDev=true`) and verify
- [ ] Verify Mac's yabai/skhd/sketchybar configs match what's actually running (may be stale from old `main`)
- [ ] Once both machines verified: make `chezmoi` the new `main`, archive old branches (`my_mac_stuff_2`, `my_work_mac`, `laptop_stuff`)
- [ ] Decide fate of `android_neovim` branch (stays separate per plan, or inline with `androidDev` gate)
