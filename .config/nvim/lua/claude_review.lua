-- claude_review.lua
-- Opens a floating terminal window showing a proposed diff for review.
-- Called by the claude-diff-hook PreToolUse hook.
local M = {}

function M.show(diff_file, response_pipe, display_script)
    local cols   = vim.o.columns
    local lines  = vim.o.lines
    local width  = math.max(80, math.floor(cols * 0.85))
    local height = math.max(20, math.floor(lines * 0.80))
    local row    = math.floor((lines  - height) / 2)
    local col    = math.floor((cols   - width)  / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative  = 'editor',
        width     = width,
        height    = height,
        row       = row,
        col       = col,
        style     = 'minimal',
        border    = 'rounded',
        title     = '  Claude Code — Review Proposed Change  ',
        title_pos = 'center',
    })

    local cmd = string.format(
        '%s %s %s',
        vim.fn.shellescape(display_script),
        vim.fn.shellescape(diff_file),
        vim.fn.shellescape(response_pipe)
    )

    vim.fn.termopen(cmd, {
        on_exit = function(_, _, _)
            vim.schedule(function()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
            end)
        end,
    })

    vim.cmd('startinsert')
end

return M
