-- Options are automatically loaded before lazy.nvim startup.
-- Keep Nvim's default context menu, but remove its mouse help entry and separator.
vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("lyre_popup_menu", { clear = true }),
    once = true,
    callback = function()
        vim.cmd([[
            silent! aunmenu PopUp.How-to\ disable\ mouse
            silent! aunmenu PopUp.-2-
        ]])
    end,
})

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Match the deliberate behavior in the VS Code configuration.
vim.g.autoformat = false
vim.g.lazyvim_picker = "telescope"
vim.g.lazyvim_explorer = "neo-tree"
vim.g.lazyvim_cmp = "blink.cmp"
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.ai_cmp = false

-- Make Mason-managed tools available before LazyFile/VeryLazy events.
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if not (vim.env.PATH or ""):find(mason_bin, 1, true) then
    vim.env.PATH = mason_bin .. ":" .. (vim.env.PATH or "")
end

-- Keep npm writes inside Neovim's own cache (used by Mason and Markdown preview).
vim.env.npm_config_cache = vim.fn.stdpath("cache") .. "/npm"

local opt = vim.opt

opt.background = "dark"
opt.expandtab = true
opt.ignorecase = false
opt.number = true
opt.relativenumber = true
opt.shiftwidth = 4
opt.showcmd = true
opt.smartcase = false
opt.softtabstop = 4
opt.tabstop = 4
opt.termguicolors = true
