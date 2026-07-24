# Avante + Dakera Integration

Seamlessly integrates Dakera persistent memory with Avante (Neovim AI editing plugin). Automatically retrieves relevant memories before sending prompts to your AI assistant.

## Features

✓ **Automatic Memory Retrieval** — Relevant memories are fetched and injected before each prompt
✓ **Interaction Logging** — Your Avante interactions are automatically stored for future reference
✓ **Async Operations** — Non-blocking memory operations don't slow down your workflow
✓ **Configurable** — Customize behavior via `lua/dakera_config.lua`
✓ **Works with All Backends** — Compatible with Claude, OpenAI, LM Studio, etc.

## Installation

Files are already installed:
- `lua/avante_dakera.lua` — Core module with Dakera API and helpers
- `lua/dakera_config.lua` — Configuration
- `after/plugin/avante_dakera.lua` — Plugin registration and commands

## Quick Start

### 1. Verify Dakera is Running

```bash
# Check from command line
curl http://localhost:3300/health

# Or in Neovim
:AvanteDakeraStatus
```

### 2. Use in Avante

Once Dakera is running, memory integration happens automatically:

1. Write your Avante prompt normally
2. Dakera retrieves relevant memories in the background
3. Memories are injected into the prompt context
4. Send to your AI backend as usual
5. Interaction is logged to Dakera for future reference

### 3. Manual Memory Management

```vim
:AvanteDakeraStore    " Store current buffer content to memory
:AvanteDakeraToggle   " Enable/disable memory injection
:AvanteDakeraStatus   " Show integration status
```

### Keybindings (Default)

```vim
<leader>ad    " Toggle memory injection
<leader>as    " Show status
<leader>am    " Store buffer to Dakera
```

## Configuration

Edit `lua/dakera_config.lua` to customize:

```lua
return {
  dakera = {
    url = "http://localhost:3300",
    api_key = "dk-test-key-12345",
    enabled = true,
  },
  
  recall = {
    enabled = true,
    top_k = 3,              -- Number of memories to retrieve
    min_relevance = 0.1,    -- Minimum relevance score
    inject_in_prompt = true,
  },

  memory = {
    agent_id = "nvim-avante",
    auto_store_interactions = true,
    importance_score = 0.7,  -- Default (0-1)
  },
}
```

## How It Works

### Prompt Enhancement

When you submit a prompt in Avante:

1. **Retrieval** — Dakera searches for memories relevant to your prompt
2. **Filtering** — Memories below min_relevance threshold are discarded
3. **Injection** — Top 3 matching memories are added to your prompt
4. **Format** — Memory context is appended with relevance scores
5. **Submit** — Enhanced prompt is sent to your LLM backend

### Memory Storage

Each Avante interaction is stored with:
- **Content** — First 150 chars of your prompt
- **Importance** — 0.6 (configurable)
- **Embedding** — 768-dimensional vector from LM Studio
- **Timestamp** — Automatic

Stored memories can be recalled in future sessions.

### Example Interaction

**Your Avante prompt:**
```
Help me refactor this Odin code for performance
```

**Retrieved memories:**
```
[Dakera Memory Context]:
• Odin prefers manual memory management for performance (95%)
• Use SIMD instructions for vectorized operations (82%)
• Profile first before optimizing (78%)
```

**Enhanced prompt sent to LLM:**
```
Help me refactor this Odin code for performance

[Dakera Memory Context]:
• Odin prefers manual memory management for performance (95%)
• Use SIMD instructions for vectorized operations (82%)
• Profile first before optimizing (78%)
```

## Commands Reference

| Command | Description |
|---------|-------------|
| `:AvanteDakeraToggle` | Enable/disable memory injection |
| `:AvanteDakeraStatus` | Show current status and server health |
| `:AvanteDakeraStore` | Manually store current buffer to memory |

## Troubleshooting

### Dakera not responding
```vim
:AvanteDakeraStatus    " Check server health
```

Ensure Dakera is running:
```bash
docker ps | grep dakera
# If not running:
docker run -d --name dakera -p 3300:3000 \
  -v dakera-data:/data \
  -e DAKERA_ROOT_API_KEY=dk-test-key-12345 \
  -e DAKERA_STORAGE=rocksdb \
  ghcr.io/dakera-ai/dakera:latest
```

### Memories not being stored
Check `lua/dakera_config.lua`:
- `auto_store_interactions = true`
- `min_content_length` (default 20 chars)

### Memories not being retrieved
- Ensure `recall.enabled = true`
- Check `recall.min_relevance` threshold (default 0.1)
- Verify prompt is > 10 characters

## Tips & Best Practices

1. **Import domain knowledge** — Manually store code patterns, standards, or architectural decisions with `:AvanteDakeraStore`

2. **Review status regularly** — Use `:AvanteDakeraStatus` to ensure integration is healthy

3. **Customize importance** — High-value memories get importance 0.8+, low-value get 0.5-0.6

4. **Monitor storage** — Memories grow ~4 KB each; 10 years at 50/day = 700 MB

5. **Disable when needed** — Use `:AvanteDakeraToggle` to disable if memories become too general

## Performance Notes

- **Memory retrieval** — Async, non-blocking (25-100ms typical)
- **Storage** — Async, non-blocking (10-50ms typical)
- **Prompt injection** — < 5ms (memory context is just text)

No performance impact on normal Neovim usage.

## Examples

### Store coding standards
```vim
" Write your coding standards in a buffer, then:
:AvanteDakeraStore
```

### Query a memory
```vim
" Type your query in Avante - relevant memories auto-inject
" e.g., "How do we handle errors in this project?"
" Memories about error handling will be retrieved and injected
```

### Disable for a prompt
```vim
:AvanteDakeraToggle    " Disable
" Send prompt without memory context
:AvanteDakeraToggle    " Re-enable
```

## Architecture

```
Avante (prompt)
    ↓
avante_dakera.lua (enhancement)
    ↓
Dakera HTTP API (semantic search)
    ↓
Retrieved memories + relevance scores
    ↓
Enhanced prompt
    ↓
LLM Backend (Claude/OpenAI/LM Studio)
```

## Further Reading

- **Dakera Setup** — See `/home/nate/projects/code/odin/ship_of_fools/`
- **Configuration** — Edit `lua/dakera_config.lua`
- **API** — Dakera server at `http://localhost:3300/`
