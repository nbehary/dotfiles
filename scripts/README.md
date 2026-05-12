# Dotfiles Skills & Scripts

Reusable tools and automation scripts for managing your Neovim and development environment.

## Available Skills

### 🔧 Kotlin LSP Setup
**File**: `setup-kotlin-lsp.sh`  
**Documentation**: `KOTLIN_LSP_SKILL.md`

Installs and configures the modern `kotlin-language-server` (FXMisc) for proper Gradle project indexing in Neovim.

**Quick Start**:
```bash
# Check setup
./setup-kotlin-lsp.sh --check

# Full setup
./setup-kotlin-lsp.sh --full

# Verify
./setup-kotlin-lsp.sh --verify
```

**Solves**:
- ✅ Kotlin LSP only seeing SDK items (not project files)
- ✅ Missing workspace symbols for project code
- ✅ No autocomplete for project classes
- ✅ Deprecation warnings from old `lspconfig` APIs
- ✅ Failed Mason installation attempts

**What it does**:
1. Installs kotlin-language-server via Homebrew
2. Configures Neovim with proper FileType autocommands
3. Sets up Gradle project root detection
4. Enables all LSP features (definitions, references, diagnostics)

**Prerequisites**:
- Neovim 0.12+
- Homebrew
- Existing Neovim config with Mason

**Testing**:
```bash
nvim src/main/kotlin/MainActivity.kt
# Inside Neovim:
<leader>ws  # Search workspace symbols - should find project classes
gd          # Go to definition
gr          # Go to references
```

---

## Usage Pattern

Each script follows a standard interface:

```bash
# Check current state
./script-name.sh --check

# Perform action
./script-name.sh --install      # Install dependencies
./script-name.sh --configure    # Apply configuration
./script-name.sh --full         # Do everything

# Verify setup
./script-name.sh --verify

# Help
./script-name.sh --help
```

---

## Directory Structure

```
scripts/
├── README.md                      ← This file
├── setup-kotlin-lsp.sh           ← Kotlin LSP setup skill
├── KOTLIN_LSP_SKILL.md           ← Detailed documentation
└── [other scripts]
```

---

## How to Add New Skills

1. Create a bash script in `scripts/` with:
   - Standard options: `--check`, `--install`, `--configure`, `--full`, `--verify`, `--help`
   - Colored output using `RED`, `GREEN`, `YELLOW`, `BLUE` variables
   - Clear error messages and status indicators
   - Proper exit codes (0 for success, 1 for failure)

2. Create a documentation file `<SCRIPT>_SKILL.md` with:
   - Problem statement
   - What gets configured
   - Usage examples
   - Troubleshooting guide
   - Testing instructions

3. Update this README with:
   - Skill name and description
   - Quick start commands
   - What it solves
   - Prerequisites

---

## Common Issues & Solutions

### Script not executable
```bash
chmod +x scripts/setup-kotlin-lsp.sh
```

### Homebrew not found
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Neovim config directory missing
```bash
mkdir -p ~/.config/nvim/{after/{plugin,ftplugin},lua}
```

### Need to reset a configuration
Delete the file and re-run `--configure`:
```bash
rm ~/.config/nvim/after/plugin/lsp-setup.lua
./setup-kotlin-lsp.sh --configure
```

---

## Quick Links

- **Kotlin LSP Skill**: [KOTLIN_LSP_SKILL.md](KOTLIN_LSP_SKILL.md)
- **Neovim Config**: `~/.config/nvim/init.lua`
- **Dotfiles**: `~/.dotfiles`

---

**Last Updated**: 2026-05-12
