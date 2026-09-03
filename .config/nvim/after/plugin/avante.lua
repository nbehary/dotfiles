-- avante.nvim configuration (LM Studio + Ollama)
pcall(function()
  -- Load avante_lib
  require('avante_lib').load()

  -- Setup Avante
  require('avante').setup({
    provider = "openai",
    auto_suggestions_provider = nil,
    providers = {
      openai = {
        endpoint = "http://127.0.0.1:1234/v1",
        model = "gemma-4-12b-qat",
        api_key_name = "", -- LM Studio doesn't require auth
        timeout = 30000,
        extra_request_body = {
          temperature = 0.2,
          max_tokens = 512,
        },
      },
      openai_mac = {
        endpoint = "http://10.0.0.246:1234/v1",
        model = "qwen3-coder-30b-a3b-instruct-mlx",
        api_key_name = "", -- LM Studio doesn't require auth
        timeout = 60000, -- higher than local: LAN + bigger model
        extra_request_body = {
          temperature = 0.2,
          max_tokens = 512,
        },
      },
      ollama = {
        endpoint = "http://127.0.0.1:11434/v1",
        model = "codellama-13b-instruct:latest",
        api_key_name = "", -- Ollama doesn't require auth
        timeout = 60000,
        temperature = 0.2,
        max_tokens = 2048,
      },
    },
    behaviour = {
      auto_suggestions = false,
      auto_suggestions_in_buffer = false,
      support_paste_from_clipboard = true,
    },
    file_selector = {
      provider = "fzf",
    },
    mappings = {
      ask = "<leader>va",
      new_ask = "<leader>vn",
      zen_mode = "<leader>vz",
      edit = "<leader>ve",
      refresh = "<leader>vr",
      focus = "<leader>vf",
      stop = "<leader>vS",
      toggle = {
        default = "<leader>vt",
        debug = "<leader>vd",
        selection = "<leader>vC",
        suggestion = "<leader>vs",
        repomap = "<leader>vR",
      },
      files = {
        add_current = "<leader>vc",
      },
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
      },
    },
    hints = { enabled = true },
    windows = {
      position = "right",
      width = 35,
      sidebar_header = {
        enabled = true,
        align = "center",
        rounded = true,
      },
      input = {
        prefix = " > ",
        height = 8,
      },
      edit = {
        border = "rounded",
        start_insert = true,
      },
      ask = {
        start_insert = true,
        border = "rounded",
      },
    },
  })
end)

-- Switch between local LM Studio and the Mac's remote LM Studio
vim.keymap.set("n", "<leader>vM", function()
  require("avante.api").switch_provider("openai_mac")
end, { desc = "Avante: switch to Mac (remote) provider" })
vim.keymap.set("n", "<leader>vL", function()
  require("avante.api").switch_provider("openai")
end, { desc = "Avante: switch to local LM Studio provider" })
vim.keymap.set("n", "<leader>vo", function()
  require("avante.api").switch_provider("ollama")
end, { desc = "Avante: switch to local Ollama (codellama-13b-instruct)" })

-- Setup dressing.nvim (Avante UI dependency)
pcall(function()
  require('dressing').setup({
    input = {
      enabled = true,
      default_prompt = "Input:",
      title_pos = "left",
      insert_only = true,
      start_in_insert = true,
      border = "rounded",
      relative = "cursor",
      prefer_width = 40,
      width = nil,
      max_width = { 140, 0.9 },
      min_width = { 20, 0.2 },
    },
    select = {
      enabled = true,
      backend = { "telescope", "fzf_lua", "fzf", "builtin" },
      trim_prompt = true,
    },
  })
end)

-- Setup render-markdown (markdown rendering for chat/code)
pcall(function()
  require('render-markdown').setup({
    heading = {
      enabled = true,
      sign = true,
      icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
    },
    code = {
      enabled = true,
      sign = false,
      style = "full",
      position = "left",
      language_header = "disabled",
    },
    checkbox = {
      enabled = true,
    },
  })
end)
