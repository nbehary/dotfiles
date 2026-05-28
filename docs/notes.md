# Repository Setup

First, clone the dotfiles repository to your local user directory (e.g., `~/dotfiles` or `~/working_dotfiles`):

```bash
git clone https://github.com/nbehary/dotfiles ~/dotfiles
cd ~/dotfiles
```

Next, checkout the `android_neovim2` branch:

```bash
git checkout android_neovim2
```

---

# Neovim Android Development Notes

Be sure to read the INSTALL.md and follow it.

This entire thing is still very much a work in progress, but nearly everything you could want is working. The only major part missing is that the DAP integration basically doesn't work. I got it to connect and hit breakpoints exactly once. I'm still working on it.

Everything is covered by the Cheat Sheet, but here are some highlights (first 2 are custom plugins I/Claude/Gemini wrote):
- `<leader>ap`: Opens a "file-tree" side panel that is setup like AS's Android Project view (so, modules -> manifest, java, res).
- When you first open an Android (gradle) project, it will scan the build configs and let you choose which you want to build with. Use `<leader>gf` for changing it later.
- Harpoon and Telescope are amazing, use them (really Telescope makes the first plugin useless).

There is no good plugin that integrates an AI chat available for Copilot, or Claude Code, or Gemini/Antigravity. I use a floaterm (`<leader>;`) with whatever CLI I'm using running inside it.

There is Copilot-backed completion though. `<C-u>` accepts. You don't want Tab, trust me (it's why the regular LSP comp accept is `<C-y>`).

Any LLM, at any level, is really, really good at working with Neovim configs. If you have issues, they will probably be able to help.

Open issues on GitHub for major things.
