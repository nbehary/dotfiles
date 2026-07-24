# Avante + Dakera: Quick Start

## What You Have

A Neovim plugin that seamlessly integrates Dakera persistent memory with Avante (your AI editing tool).

### How It Works

```
You type Avante prompt
    ↓
Dakera searches for relevant memories
    ↓
Memories are injected into prompt
    ↓
Enhanced prompt sent to your LLM
    ↓
Interaction is stored in Dakera
```

## In 2 Minutes

### 1. Restart Neovim
The plugin loads automatically. You should see:
```
✓ Avante + Dakera initialized
```

### 2. Use Avante Normally
Write prompts as usual. Memories are fetched automatically in the background.

### 3. Done!
Your prompts now have memory context, and interactions are stored for future reference.

## Commands

```vim
:AvanteDakeraStatus    " Check if Dakera is connected ✓
:AvanteDakeraToggle    " Disable/enable memory injection
:AvanteDakeraStore     " Manually save buffer to memory
```

## Keybindings

```vim
<leader>ad    " Toggle memory injection
<leader>as    " Show status
<leader>am    " Store buffer to Dakera
```

## Verify It's Working

1. Open any file in Neovim
2. Press `<leader>as` (status check)
3. Should show: `Dakera: ✓ Healthy`

If it shows "Unreachable":
```bash
# Check Dakera is running
docker ps | grep dakera
```

## Configuration

Edit `~/.config/nvim/lua/dakera_config.lua` to customize:

```lua
-- Disable memory injection
recall.inject_in_prompt = false,

-- Change how many memories to retrieve
recall.top_k = 5,  -- default 3

-- Disable auto-storing interactions
memory.auto_store_interactions = false,
```

## Example Use Case

**Store your project's coding standards:**
```vim
" 1. Write standards in a new buffer
" 2. :AvanteDakeraStore
" 3. Future prompts will include these standards automatically
```

**Ask Avante about project patterns:**
```vim
" :Avante
" Prompt: "How should we handle errors?"
" ↓
" Dakera retrieves your error-handling memories
" ↓ 
" Standards injected into prompt
" ↓
" LLM responds with context-aware answer
```

## Troubleshooting

### "Dakera server not available"
```bash
cd ~/projects/code/odin/ship_of_fools
source .venv/bin/activate
python dakera_lm_studio_integration.py
# Or restart Dakera container:
docker run -d --name dakera -p 3300:3000 -v dakera-data:/data \
  -e DAKERA_ROOT_API_KEY=dk-test-key-12345 \
  ghcr.io/dakera-ai/dakera:latest
```

### Memories not appearing
- Check `:AvanteDakeraStatus`
- Verify `recall.enabled = true` in config
- Make sure prompt is relevant to stored memories

### Too many memories appearing
- Increase `recall.min_relevance` (e.g., 0.3 instead of 0.1)
- Decrease `recall.top_k` (e.g., 2 instead of 3)

## Files

```
~/.config/nvim/
├── lua/
│   ├── avante_dakera.lua       " Core module (auto-loaded)
│   └── dakera_config.lua       " Configuration (edit this)
├── after/plugin/
│   └── avante_dakera.lua       " Plugin registration
├── AVANTE_DAKERA_README.md     " Full documentation
└── AVANTE_DAKERA_QUICK_START.md " This file
```

## Next Steps

1. **Store important context** — Use `:AvanteDakeraStore` on project standards
2. **Monitor status** — Run `:AvanteDakeraStatus` to ensure server health
3. **Customize config** — Edit `lua/dakera_config.lua` for your workflow
4. **Keep Dakera running** — It needs to be accessible for memory injection

## Enjoy!

Your Neovim AI assistant now has persistent memory. 🚀
