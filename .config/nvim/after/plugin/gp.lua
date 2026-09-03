-- gp.nvim configuration (using local Ollama with Qwen 2.5 Coder 14B or Deepseek R1 32B)
pcall(function()
  require("gp").setup({
    providers = {
      ollama = {
        disable = false,
        endpoint = "http://localhost:11434/v1/chat/completions",
        secret = "dummy_secret_not_used_by_ollama",
      },
    },
    default_chat_agent = "ChatOllama",
    default_command_agent = "CodeOllama",
    agents = {
      {
        provider = "ollama",
        name = "ChatOllama",
        chat = true,
        command = false,
        model = { model = "qwen2.5-coder:14b", temperature = 0.6, top_p = 0.9 },
        system_prompt = "You are a helpful AI assistant. Answer concisely and accurately.",
      },
      {
        provider = "ollama",
        name = "ChatDeepseekR1",
        chat = true,
        command = false,
        model = { model = "deepseek-r1:32b", temperature = 0.6, top_p = 0.9 },
        system_prompt = "You are a reasoning AI assistant. Think step-by-step and show your reasoning.",
      },
      {
        provider = "ollama",
        name = "CodeOllama",
        chat = false,
        command = true,
        model = { model = "qwen2.5-coder:14b", temperature = 0.1 },
        system_prompt = "You are an expert coder. Output ONLY valid code block replacements without explanations unless requested.",
      },
    },
  })

  -- Keymaps
  local function keymapOptions(desc)
    return {
      noremap = true,
      silent = true,
      nowait = true,
      desc = "GPT: " .. desc,
    }
  end

  -- Chat commands
  vim.keymap.set({"n", "i"}, "<C-g>c", "<cmd>GpChatNew<cr>", keymapOptions("New Chat"))
  vim.keymap.set({"n", "i"}, "<C-g>t", "<cmd>GpChatToggle<cr>", keymapOptions("Toggle Chat"))
  vim.keymap.set({"n", "i"}, "<C-g>f", "<cmd>GpChatFinder<cr>", keymapOptions("Find Chat"))

  vim.keymap.set("v", "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", keymapOptions("New Chat from selection"))
  vim.keymap.set("v", "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", keymapOptions("Paste into Chat"))
  vim.keymap.set("v", "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", keymapOptions("Toggle Chat from selection"))

  -- Prompt commands
  vim.keymap.set({"n", "i"}, "<C-g>r", "<cmd>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
  vim.keymap.set({"n", "i"}, "<C-g>a", "<cmd>GpAppend<cr>", keymapOptions("Append"))
  vim.keymap.set({"n", "i"}, "<C-g>b", "<cmd>GpPrepend<cr>", keymapOptions("Prepend"))
  vim.keymap.set({"n", "i"}, "<C-g>e", "<cmd>GpEnew<cr>", keymapOptions("Rewrite in new buffer"))

  vim.keymap.set("v", "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
  vim.keymap.set("v", "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", keymapOptions("Append selection"))
  vim.keymap.set("v", "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", keymapOptions("Prepend selection"))
  vim.keymap.set("v", "<C-g>e", ":<C-u>'<,'>GpEnew<cr>", keymapOptions("Rewrite selection in new buffer"))
end)
