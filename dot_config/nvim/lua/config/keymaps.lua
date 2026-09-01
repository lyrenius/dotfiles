-- Leap mappings are provided by LazyVim's editor.leap extra:
-- `s` jumps forward, `S` jumps backward, and `gs` jumps across windows.

-- Restore Neovim's native linewise movement. LazyVim maps these keys to
-- gj/gk when no count is given, which moves by wrapped screen lines instead.
for _, key in ipairs({ "j", "k", "<Down>", "<Up>" }) do
    pcall(vim.keymap.del, { "n", "x" }, key)
end
