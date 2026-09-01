return {
    {
        "mrjones2014/smart-splits.nvim",
        lazy = false,
        opts = {
            default_amount = 3,
            ignored_filetypes = {
                "NvimTree",
                "neo-tree",
            },
        },
        config = function(_, opts)
            local smart_splits = require("smart-splits")
            smart_splits.setup(opts)

            local mappings = {
                ["<C-h>"] = smart_splits.move_cursor_left,
                ["<C-j>"] = smart_splits.move_cursor_down,
                ["<C-k>"] = smart_splits.move_cursor_up,
                ["<C-l>"] = smart_splits.move_cursor_right,
            }

            local function set_mappings()
                for key, action in pairs(mappings) do
                    vim.keymap.set({ "n", "t" }, key, action, {
                        silent = true,
                        desc = "Move across Nvim/tmux panes",
                    })
                end
            end

            if vim.v.vim_did_enter == 1 then
                vim.schedule(set_mappings)
            else
                vim.api.nvim_create_autocmd("User", {
                    group = vim.api.nvim_create_augroup("lyre_smart_splits_keymaps", { clear = true }),
                    pattern = "LazyVimKeymaps",
                    once = true,
                    callback = set_mappings,
                })
            end
        end,
    },
}
