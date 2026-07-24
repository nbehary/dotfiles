-- ============================================================================
-- Avante + Dakera Integration Plugin
-- ============================================================================
-- Main plugin file that registers commands and hooks into Avante
-- ============================================================================

local ok, dakera = pcall(require, "avante_dakera")
if not ok then
  vim.notify("Failed to load avante_dakera module", vim.log.levels.ERROR)
  return
end

-- ============================================================================
-- Commands
-- ============================================================================

vim.api.nvim_create_user_command("AvanteDakeraToggle", function()
  local enabled = dakera.toggle_enabled()
  local status = enabled and "enabled" or "disabled"
  vim.notify("Avante + Dakera: " .. status, vim.log.levels.INFO)
end, {
  desc = "Toggle Avante + Dakera memory injection",
})

vim.api.nvim_create_user_command("AvanteDakeraStatus", function()
  local status = dakera.get_status()
  vim.notify(
    string.format(
      "Avante + Dakera Status\n" ..
      "Enabled: %s\n" ..
      "Agent ID: %s\n" ..
      "Server: %s\n" ..
      "Auto-store: %s\n" ..
      "Inject: %s",
      status.enabled and "✓ Yes" or "✗ No",
      status.agent_id,
      status.url,
      status.auto_store and "✓ Yes" or "✗ No",
      status.inject_in_prompt and "✓ Yes" or "✗ No"
    ),
    vim.log.levels.INFO
  )
end, {
  desc = "Show Avante + Dakera status",
})

vim.api.nvim_create_user_command("AvanteDakeraStore", function()
  dakera.manual_store_current_buffer()
  vim.notify("Buffer stored to Dakera", vim.log.levels.INFO)
end, {
  desc = "Manually store current buffer to Dakera",
})

-- ============================================================================
-- Keybindings (Optional - customize as needed)
-- ============================================================================

-- Toggle: <leader>ad
vim.keymap.set("n", "<leader>ad", ":AvanteDakeraToggle<CR>", {
  noremap = true,
  silent = true,
  desc = "Toggle Avante + Dakera",
})

-- Show status: <leader>as
vim.keymap.set("n", "<leader>as", ":AvanteDakeraStatus<CR>", {
  noremap = true,
  silent = true,
  desc = "Avante + Dakera status",
})

-- Store buffer: <leader>am
vim.keymap.set("n", "<leader>am", ":AvanteDakeraStore<CR>", {
  noremap = true,
  silent = true,
  desc = "Store buffer to Dakera",
})

-- ============================================================================
-- Health Check on Startup (Synchronous with fallback)
-- ============================================================================

-- Synchronous health check using curl
local function check_dakera_sync()
  local result = vim.fn.system("curl -s -f http://localhost:3300/health")
  return vim.v.shell_error == 0
end

-- Try synchronous check first
if check_dakera_sync() then
  vim.notify("✓ Avante + Dakera initialized", vim.log.levels.INFO)
else
  -- Fallback: try async check after a delay
  vim.defer_fn(function()
    dakera.check_health(function(healthy)
      if healthy then
        vim.notify("✓ Avante + Dakera now online", vim.log.levels.INFO)
      else
        vim.notify(
          "⚠ Dakera server not responding - memory features unavailable",
          vim.log.levels.WARN
        )
      end
    end)
  end, 1000)
end

-- ============================================================================
-- Wire automatic memory injection into Avante's real submit path
-- ============================================================================
-- Avante has no public hook for this. Both direct typing in the sidebar
-- (submit_input -> handle_submit) and the AvanteInputSubmitted autocmd
-- listener funnel through Sidebar:handle_submit, so that's the one place
-- to patch. Recall is async with a hard timeout fallback so a slow/dead
-- Dakera server degrades to a plain, un-enhanced submit instead of hanging.
local ok_sidebar, Sidebar = pcall(require, "avante.sidebar")
if ok_sidebar and not Sidebar.__dakera_patched then
  local original_handle_submit = Sidebar.handle_submit

  Sidebar.handle_submit = function(self, request)
    dakera.on_avante_submit(request)

    local dakera_cfg = require("dakera_config")
    if not dakera_cfg.recall.enabled or not dakera_cfg.recall.inject_in_prompt then
      original_handle_submit(self, request)
      return
    end

    local submitted = false
    local function do_submit(final_request)
      if submitted then return end
      submitted = true
      original_handle_submit(self, final_request)
    end

    local timer = vim.defer_fn(function() do_submit(request) end, 1500)

    dakera.enhance_prompt_with_memories(request, function(enhanced)
      pcall(function() timer:stop() end)
      vim.schedule(function() do_submit(enhanced or request) end)
    end)
  end

  Sidebar.__dakera_patched = true
end
