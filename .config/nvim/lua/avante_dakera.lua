-- ============================================================================
-- Avante + Dakera Bridge (Core Module)
-- ============================================================================
-- Main logic for integrating Avante with Dakera persistent memory
-- ============================================================================

local M = {}
local config = require("dakera_config")

-- ============================================================================
-- HTTP Utilities (Async)
-- ============================================================================

local function make_http_request(method, endpoint, body, callback)
  -- Make async HTTP request to Dakera
  local dakera_url = config.dakera.url
  local dakera_api_key = config.dakera.api_key

  local curl_args = {
    method,
    dakera_url .. endpoint,
    "-m", "2", -- bound worst-case latency so a dead server can't hang prompt submission
    "-H", "Authorization: Bearer " .. dakera_api_key,
    "-H", "Content-Type: application/json",
  }

  if body then
    table.insert(curl_args, "-d")
    table.insert(curl_args, vim.fn.json_encode(body))
  end

  vim.fn.jobstart({ "curl", "-s", unpack(curl_args) }, {
    on_stdout = function(_, output, _)
      if not output or #output == 0 then
        if callback then callback(nil) end
        return
      end

      local result = table.concat(output, "")
      local ok, decoded = pcall(vim.fn.json_decode, result)

      if callback then
        callback(ok and decoded or nil)
      end
    end,
    on_stderr = function(_, err, _)
      if callback and err and #err > 0 then
        callback(nil)
      end
    end,
  })
end

-- ============================================================================
-- Dakera API
-- ============================================================================

function M.recall_memories(query, top_k, callback)
  -- Fetch relevant memories from Dakera (async)
  if not config.dakera.enabled then
    if callback then callback({}) end
    return
  end

  local cfg = config.memory
  top_k = top_k or config.recall.top_k

  make_http_request("POST", "/v1/memory/recall", {
    agent_id = cfg.agent_id,
    query = query,
    top_k = top_k,
  }, function(response)
    if not response or not response.memories then
      if callback then callback({}) end
      return
    end

    local memories = {}
    local min_relevance = config.recall.min_relevance

    for _, mem in ipairs(response.memories) do
      if mem.score >= min_relevance then
        table.insert(memories, {
          content = mem.memory.content,
          score = mem.score,
          timestamp = mem.memory.created_at,
        })
      end
    end

    if callback then callback(memories) end
  end)
end

function M.store_memory(content, importance, callback)
  -- lua doc
  if not config.dakera.enabled or not config.memory.auto_store_interactions then
    if callback then callback(false) end
    return
  end

  if #content < config.memory.min_content_length then
    if callback then callback(false) end
    return
  end

  make_http_request("POST", "/v1/memory/store", {
    agent_id = config.memory.agent_id,
    content = content,
    importance = importance or config.memory.importance_score,
  }, function(response)
    if callback then
      callback(response ~= nil)
    end
  end)
end

function M.check_health(callback)
  -- lua doc
  make_http_request("GET", "/health", nil, function(response)
    if callback then
      callback(response and response.status == "healthy")
    end
  end)
end

-- ============================================================================
-- Prompt Enhancement
-- ============================================================================

function M.enhance_prompt_with_memories(prompt, callback)
  -- lua doc
  if not config.recall.enabled or not config.recall.inject_in_prompt then
    if callback then callback(prompt) end
    return
  end

  if not prompt or prompt == "" then
    if callback then callback(prompt) end
    return
  end

  M.recall_memories(prompt, config.recall.top_k, function(memories)
    if not memories or #memories == 0 then
      if callback then callback(prompt) end
      return
    end

    local context = "\n\n[Dakera Memory Context]:\n"
    for i, mem in ipairs(memories) do
      context = context .. string.format(
        "• %s (relevance: %d%%)\n",
        mem.content:sub(1, 100),
        math.floor(mem.score * 100)
      )
    end

    if callback then
      callback(prompt .. context)
    end
  end)
end

-- ============================================================================
-- Integration Points
-- ============================================================================

function M.on_avante_submit(prompt)
  -- lua doc
  if not config.dakera.enabled then
    return prompt
  end

  -- Store the interaction asynchronously
  if config.memory.auto_store_interactions and #prompt > config.memory.min_content_length then
    M.store_memory(
      string.format("[Avante] %s", prompt:sub(1, 150)),
      0.6
    )
  end

  return prompt
end

function M.get_memory_preview()
  -- lua doc
  local count = 0
  M.recall_memories("memory", 1, function(memories)
    if memories then
      count = #memories
    end
  end)
  return count
end

-- ============================================================================
-- User-facing Functions
-- ============================================================================

function M.toggle_enabled()
  -- lua doc
  config.dakera.enabled = not config.dakera.enabled
  return config.dakera.enabled
end

function M.get_status()
  -- lua doc
  return {
    enabled = config.dakera.enabled,
    agent_id = config.memory.agent_id,
    url = config.dakera.url,
    auto_store = config.memory.auto_store_interactions,
    inject_in_prompt = config.recall.inject_in_prompt,
  }
end

function M.manual_store_current_buffer()
  -- lua doc
  local buf = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, 30, false)

  local content = table.concat(lines, "\n")
  if #content > 500 then
    content = content:sub(1, 500)
  end

  local filename = vim.fn.fnamemodify(bufname, ":t")
  M.store_memory(
    string.format("[%s]\n%s", filename, content),
    0.8,
    function(success)
      if success and config.ui.notify_on_store then
        vim.notify("Stored to Dakera", vim.log.levels.INFO)
      end
    end
  )
end

return M
