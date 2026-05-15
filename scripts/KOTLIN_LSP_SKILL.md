# Kotlin LSP Setup Skill

A comprehensive Neovim configuration skill that installs and configures the modern Kotlin Language Server for proper project indexing and LSP support in Gradle projects.

## Problem Solved

When Neovim is configured with an outdated or misconfigured Kotlin LSP, it:
- Only indexes SDK items, not project files
- Fails to resolve symbols across modules
- Provides no autocomplete or diagnostics for project code
- May encounter deprecation warnings with old `lspconfig` APIs

## What This Skill Does

1. **Installs** the modern `kotlin-language-server` (FXMisc) via Homebrew
2. **Configures** Neovim LSP to use proper FileType autocommands (not deprecated `lspconfig`)
3. **Sets up** Gradle project root detection for multi-module builds
4. **Enables** full LSP features: workspace symbols, definitions, references, diagnostics, completions
5. **Verifies** the entire setup is working correctly

## Prerequisites

- Neovim 0.12+
- Homebrew (for installation)
- Existing Neovim configuration with Mason and lazy.nvim

## Usage

### Check Current Setup
```bash
./scripts/setup-kotlin-lsp.sh --check
```
Verifies if Kotlin LSP is installed and accessible.

### Full Setup from Scratch
```bash
./scripts/setup-kotlin-lsp.sh --full
```
Runs all steps: installs kotlin-language-server, configures Neovim, and verifies.

### Individual Steps
```bash
# Install only
./scripts/setup-kotlin-lsp.sh --install

# Configure Neovim only
./scripts/setup-kotlin-lsp.sh --configure

# Verify setup
./scripts/setup-kotlin-lsp.sh --verify
```

## What Gets Configured

### 1. Installation
- **Binary**: `/opt/homebrew/bin/kotlin-language-server` (via Homebrew)
- **Version**: Latest stable (1.3.13+)

### 2. Neovim Configuration
File: `~/.config/nvim/after/plugin/lsp-setup.lua`

Creates FileType autocommands that:
- Auto-start kotlin-language-server when opening `.kt` files
- Detect Gradle project roots via `build.gradle`, `settings.gradle`, `pom.xml`, or `.git`
- Configure LSP capabilities and settings:
  - JVM target: 21
  - Linting enabled
  - Snippets enabled
  - Diagnostics enabled

### 3. LSP Keymaps (via LspAttach)
Once LSP is attached:
- `gd` — Go to definition
- `gr` — Go to references  
- `gI` — Go to implementation
- `<leader>D` — Type definition
- `<leader>ds` — Document symbols
- `<leader>ws` — Workspace symbols (**crucial for project indexing**)
- `<leader>rn` — Rename
- `<leader>ca` — Code actions
- `K` — Hover documentation
- `gD` — Go to declaration

## Testing the Setup

1. **Open a Kotlin file in your project:**
   ```bash
   nvim src/main/kotlin/MainActivity.kt
   ```

2. **Verify LSP attachment:**
   Inside Neovim, run: `:LspInfo`
   You should see `kotlin-language-server` listed as `active`.

3. **Test workspace symbols:**
   Press `<leader>ws` and search for a class name from your project (not just SDK).
   Results should include your project's classes, not just standard library.

4. **Test other features:**
   - `gd` on a class → jumps to its definition
   - `gr` on a symbol → shows all references
   - `K` on a function → shows documentation
   - Type incomplete code → autocomplete suggestions appear

## Troubleshooting

### kotlin-language-server not found
```bash
which kotlin-language-server
```
If not found, run: `./scripts/setup-kotlin-lsp.sh --install`

### LSP not attaching to buffers
Check Neovim logs:
```bash
tail -f ~/.local/share/nvim/lsp.log
```

Verify the config file exists and is valid:
```bash
cat ~/.config/nvim/after/plugin/lsp-setup.lua
```

### Only SDK items in workspace symbols
- Ensure you're in the project root (where `build.gradle` or `settings.gradle` exists)
- Run `:LspInfo` to confirm LSP is attached
- Check that `root_dir` is detected correctly with `:lua print(vim.lsp.get_clients()[1].config.root_dir)`

### JVM target mismatch
If you're using JVM 17 instead of 21, edit `~/.config/nvim/after/plugin/lsp-setup.lua`:
```lua
jvm = {
  target = '17',  -- Change from '21'
},
```

## Configuration Details

### Kotlin LSP Settings
```lua
settings = {
  kotlin = {
    compiler = {
      jvm = {
        target = '21',  -- Adjust to match your project's JVM version
      },
    },
    linting = { enabled = true },
    completion = { snippets = { enabled = true } },
    diagnostics = { enabled = true },
  },
}
```

### Root Directory Detection
The LSP scans upward from the open file looking for project markers:
1. `build.gradle` or `build.gradle.kts` (Gradle projects)
2. `settings.gradle` or `settings.gradle.kts` (Gradle multi-module)
3. `pom.xml` (Maven projects)
4. `.git` (Git repository root)

The first match becomes the project root for LSP indexing.

## Performance Notes

- **First run**: LSP may take 10-30 seconds to index a large project
- **Workspace symbols**: First search may be slower as LSP builds the index
- **Subsequent runs**: Symbols are cached for faster lookups

## Files Modified/Created

- ✅ `/opt/homebrew/bin/kotlin-language-server` (installed)
- ✅ `~/.config/nvim/after/plugin/lsp-setup.lua` (created/updated)
- ✅ `~/.config/nvim/after/plugin/` (directory created if needed)

## Related Features

- **Java LSP**: Configured separately via `~/.config/nvim/after/ftplugin/java.lua` (uses `jdtls`)
- **Lua LSP**: Also configured in the same `lsp-setup.lua` file
- **Formatters**: ktlint (Kotlin), stylua (Lua) are installed via Mason

## Advanced: Custom JVM Target

If your project uses a different JVM target:

```bash
# Edit the config
nvim ~/.config/nvim/after/plugin/lsp-setup.lua

# Change the jvm.target setting:
jvm = { target = '17' }  # or '11', '8', etc.

# Reload Neovim
:source %
```

## When to Use This Skill

Use this skill when:
- ✅ Setting up Kotlin LSP for the first time
- ✅ Migrating from old `kotlin_lsp` (IntelliJ-based)
- ✅ Fixing "only sees SDK items" problem
- ✅ Updating to use modern FXMisc kotlin-language-server
- ✅ Reconfiguring after Gradle/JVM updates

Don't use if:
- ❌ Using a different editor (VSCode, IntelliJ, etc.)
- ❌ Your project doesn't use Kotlin
- ❌ You prefer alternative Kotlin tooling

## See Also

- [kotlin-language-server GitHub](https://github.com/fwcd/kotlin-language-server)
- [Neovim LSP Docs](https://neovim.io/doc/user/lsp.html)
- [Gradle Documentation](https://gradle.org/docs/)
