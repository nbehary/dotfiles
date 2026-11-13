#!/bin/bash
# Kotlin LSP Setup Skill
# Configures Neovim with proper Kotlin Language Server support for Gradle projects
# Usage: ./setup-kotlin-lsp.sh [--check] [--install] [--configure]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration paths
NVIM_CONFIG_DIR="${HOME}/.config/nvim"
LSP_SETUP_FILE="${NVIM_CONFIG_DIR}/after/plugin/lsp-setup.lua"
KOTLIN_FTPLUGIN="${NVIM_CONFIG_DIR}/after/ftplugin/kotlin.lua"

# Functions
print_header() {
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

print_info() {
  echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if Kotlin LSP is installed
check_kotlin_lsp() {
  print_header "Checking Kotlin LSP Installation"
  
  if command -v kotlin-language-server &> /dev/null; then
    local version=$(kotlin-language-server --version 2>/dev/null || echo "unknown")
    print_success "kotlin-language-server found: $version"
    return 0
  else
    print_error "kotlin-language-server not found in PATH"
    return 1
  fi
}

# Check if Neovim config exists
check_neovim_config() {
  print_header "Checking Neovim Configuration"
  
  if [ ! -d "$NVIM_CONFIG_DIR" ]; then
    print_error "Neovim config directory not found: $NVIM_CONFIG_DIR"
    return 1
  fi
  
  print_success "Neovim config directory found: $NVIM_CONFIG_DIR"
  
  if [ ! -d "${NVIM_CONFIG_DIR}/after/plugin" ]; then
    print_info "Creating after/plugin directory..."
    mkdir -p "${NVIM_CONFIG_DIR}/after/plugin"
  fi
  
  if [ ! -d "${NVIM_CONFIG_DIR}/after/ftplugin" ]; then
    print_info "Creating after/ftplugin directory..."
    mkdir -p "${NVIM_CONFIG_DIR}/after/ftplugin"
  fi
  
  return 0
}

# Install Kotlin LSP via Homebrew
install_kotlin_lsp() {
  print_header "Installing Kotlin LSP"
  
  if ! command -v brew &> /dev/null; then
    print_error "Homebrew not found. Please install Homebrew first."
    print_info "Visit: https://brew.sh"
    return 1
  fi
  
  if command -v kotlin-language-server &> /dev/null; then
    print_info "kotlin-language-server already installed"
    return 0
  fi
  
  print_info "Installing kotlin-language-server via Homebrew..."
  if brew install kotlin-language-server; then
    print_success "kotlin-language-server installed successfully"
    return 0
  else
    print_error "Failed to install kotlin-language-server"
    return 1
  fi
}

# Configure LSP setup file
configure_lsp_setup() {
  print_header "Configuring Neovim LSP Setup"
  
  # Create the LSP setup configuration
  cat > "$LSP_SETUP_FILE" << 'EOF'
-- LSP Configuration
-- Defer setup until plugins are available

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('lsp-setup-defer', { clear = true }),
  callback = function()
    -- Set up Mason first
    require('mason').setup()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    require('mason-tool-installer').setup {
      ensure_installed = {
        'ktlint',
        'jdtls',
        'stylua',
        'java-debug-adapter',
        'kotlin-debug-adapter',
      },
      skip_update = false,
    }
  end,
  once = true,
})

-- Manually start Kotlin LSP on FileType
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'kotlin',
  group = vim.api.nvim_create_augroup('kotlin-lsp-start', { clear = true }),
  callback = function(event)
    local bufnr = event.buf

    -- Check if already attached
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    if #clients > 0 then
      return
    end

    -- Start kotlin-language-server
    vim.lsp.start {
      name = 'kotlin-language-server',
      cmd = { 'kotlin-language-server' },
      bufnr = bufnr,
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      settings = {
        kotlin = {
          compiler = {
            jvm = {
              target = '21',
            },
          },
          linting = {
            enabled = true,
          },
          completion = {
            snippets = {
              enabled = true,
            },
          },
          diagnostics = {
            enabled = true,
          },
        },
      },
      root_dir = vim.fs.dirname(vim.fs.find({ 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'pom.xml', '.git' }, { upward = true })[1] or '.'),
    }
  end,
})

-- Manually start Lua LSP on FileType
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  group = vim.api.nvim_create_augroup('lua-lsp-start', { clear = true }),
  callback = function(event)
    local bufnr = event.buf

    -- Check if already attached
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    if #clients > 0 then
      return
    end

    -- Start lua-language-server
    vim.lsp.start {
      name = 'lua-language-server',
      cmd = { 'lua-language-server' },
      bufnr = bufnr,
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          workspace = {
            checkThirdParty = false,
            library = {
              '${3rd}/luv/library',
              unpack(vim.api.nvim_get_runtime_file('', true)),
            },
          },
          completion = {
            callSnippet = 'Replace',
          },
        },
      },
    }
  end,
})

-- LspAttach autocommand for keymaps (can run at startup)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
EOF
  
  if [ $? -eq 0 ]; then
    print_success "LSP setup configured: $LSP_SETUP_FILE"
    return 0
  else
    print_error "Failed to write LSP setup file"
    return 1
  fi
}

# Verify the setup works
verify_setup() {
  print_header "Verifying Kotlin LSP Setup"
  
  local status=0
  
  # Check binary
  if ! command -v kotlin-language-server &> /dev/null; then
    print_error "kotlin-language-server not in PATH"
    status=1
  else
    print_success "kotlin-language-server executable found"
  fi
  
  # Check LSP setup file
  if [ ! -f "$LSP_SETUP_FILE" ]; then
    print_error "LSP setup file not found: $LSP_SETUP_FILE"
    status=1
  else
    print_success "LSP setup file exists: $LSP_SETUP_FILE"
    
    # Verify key components
    if grep -q "kotlin-language-server" "$LSP_SETUP_FILE"; then
      print_success "kotlin-language-server configuration found"
    else
      print_error "kotlin-language-server configuration not found"
      status=1
    fi
    
    if grep -q "build.gradle" "$LSP_SETUP_FILE"; then
      print_success "Gradle root detection configured"
    else
      print_error "Gradle root detection not configured"
      status=1
    fi
  fi
  
  return $status
}

# Main flow
main() {
  local mode="${1:---check}"
  
  case "$mode" in
    --check)
      check_neovim_config && check_kotlin_lsp
      ;;
    --install)
      check_neovim_config && install_kotlin_lsp
      ;;
    --configure)
      check_neovim_config && configure_lsp_setup
      ;;
    --full|--all)
      check_neovim_config && install_kotlin_lsp && configure_lsp_setup && verify_setup
      ;;
    --verify)
      verify_setup
      ;;
    --help)
      cat << 'HELP'
Kotlin LSP Setup Skill

Usage: ./setup-kotlin-lsp.sh [OPTION]

Options:
  --check       Check if Kotlin LSP is installed and Neovim is configured (default)
  --install     Install kotlin-language-server via Homebrew
  --configure   Configure Neovim LSP setup file
  --full        Run all steps: check, install, configure, and verify
  --verify      Verify the setup is correct
  --help        Show this help message

Examples:
  # Check current state
  ./setup-kotlin-lsp.sh --check

  # Full setup from scratch
  ./setup-kotlin-lsp.sh --full

  # Reconfigure after changes
  ./setup-kotlin-lsp.sh --configure

Notes:
  - Requires Homebrew for installation
  - Requires existing Neovim configuration
  - Creates after/plugin and after/ftplugin directories if needed
  - Overwrites existing lsp-setup.lua configuration

HELP
      ;;
    *)
      print_error "Unknown option: $mode"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
  
  exit $?
}

main "$@"
