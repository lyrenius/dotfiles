return {
    {
        "github/copilot.vim",
        cmd = "Copilot",
        event = "InsertEnter",

        init = function()
            -- Blink owns the final Tab mapping and calls Copilot explicitly.
            vim.g.copilot_no_tab_map = true
        end,

        dependencies = {
            "saghen/blink.cmp",
        },

        config = function()
            LazyVim.cmp.actions.ai_accept = function()
                if vim.g.loaded_copilot ~= 1 then
                    return
                end

                local ok, suggestion = pcall(vim.fn["copilot#GetDisplayedSuggestion"])
                if not ok or type(suggestion) ~= "table" or suggestion.text == "" then
                    return
                end

                local keys = vim.fn["copilot#Accept"]("")
                if keys == "" then
                    return
                end

                LazyVim.create_undo()
                vim.api.nvim_feedkeys(keys, "in", true)
                return true
            end
        end,
    },
}
