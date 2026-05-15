local M = {}

local function config_dir(root_dir)
  return root_dir .. '/.nvim'
end

local function config_file(root_dir)
  return config_dir(root_dir) .. '/project.json'
end

local function ensure_config_dir(root_dir)
  local dir = config_dir(root_dir)
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
end

function M.load_config(root_dir)
  local file = config_file(root_dir)
  if vim.fn.filereadable(file) == 0 then
    return nil
  end
  local content = vim.fn.readfile(file)
  local json_str = table.concat(content, '\n')
  local ok, config = pcall(vim.json.decode, json_str)
  if not ok then
    return nil
  end
  return config
end

function M.save_config(root_dir, config)
  ensure_config_dir(root_dir)
  local file = config_file(root_dir)
  local json_str = vim.json.encode(config)
  vim.fn.writefile(vim.split(json_str, '\n'), file)
end

function M.get_install_task(root_dir)
  local config = M.load_config(root_dir)
  if not config or not config.install_task then
    return nil
  end
  return config.install_task
end

function M.set_install_task(root_dir, task)
  local config = M.load_config(root_dir) or { version = 1 }
  config.install_task = task
  config.project_root = root_dir
  M.save_config(root_dir, config)
end

return M
