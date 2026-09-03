local ok, diffbandit = pcall(require, "diffbandit")
if ok then
  diffbandit.setup()
  
  -- DiffBandit keybindings
  vim.keymap.set("n", "<leader>db", ":DiffBanditGit<CR>", { desc = "DiffBandit (Git Status)" })
  vim.keymap.set("n", "<leader>dc", ":DiffBanditCommitPanel<CR>", { desc = "DiffBandit Commit Panel" })
  vim.keymap.set("n", "<leader>df", ":DiffBanditGitCurrent<CR>", { desc = "DiffBandit Current File" })
end
