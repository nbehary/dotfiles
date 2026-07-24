-- ============================================================================
-- Dakera Configuration for Avante
-- ============================================================================

return {
  -- Dakera server settings
  dakera = {
    url = "http://localhost:3300",
    api_key = "dk-test-key-12345",
    enabled = true,
  },

  -- Memory storage settings
  memory = {
    agent_id = "nvim-avante",
    auto_store_interactions = true,
    min_content_length = 20,  -- Minimum chars to store
    importance_score = 0.7,    -- Default importance (0-1)
  },

  -- Memory recall settings
  recall = {
    enabled = true,
    top_k = 3,                 -- Number of memories to retrieve
    min_relevance = 0.1,       -- Minimum relevance score (0-1)
    inject_in_prompt = true,   -- Add memories to prompt
  },

  -- UI/Display settings
  ui = {
    show_status_on_startup = true,
    show_memory_in_statusline = true,
    notify_on_store = false,   -- Notify when memories are stored
  },
}
