-- Setup android-variant-picker.nvim
local ok, picker = pcall(require, 'android-variant-picker')
if ok then
  picker.setup()
end
