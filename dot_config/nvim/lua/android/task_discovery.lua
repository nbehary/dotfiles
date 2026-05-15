local M = {}

function M.discover_install_tasks(root_dir)
  local gradlew = root_dir .. '/gradlew'
  if vim.fn.executable(gradlew) == 0 then
    return {}
  end

  local output = vim.fn.systemlist(gradlew .. ' tasks --all 2>/dev/null')
  if vim.v.shell_error ~= 0 then
    return {}
  end

  local tasks = {}
  for _, line in ipairs(output) do
    local task = line:match '^%s*([a-zA-Z0-9:]+Install[a-zA-Z0-9]*)'
    if task then
      table.insert(tasks, task)
    end
  end

  return tasks
end

function M.select_install_task(tasks, callback)
  if #tasks == 0 then
    vim.notify('No install tasks found', vim.log.levels.WARN)
    callback(nil)
    return
  end

  if #tasks == 1 then
    callback(tasks[1])
    return
  end

  vim.ui.select(tasks, { prompt = 'Select install task:' }, function(choice)
    callback(choice)
  end)
end

return M
