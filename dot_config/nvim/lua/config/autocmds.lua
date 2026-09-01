local indent_group = vim.api.nvim_create_augroup("lyre_four_space_indent", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = indent_group,
    pattern = "*",
    callback = function(args)
        local options = vim.bo[args.buf]
        options.tabstop = 4
        options.shiftwidth = 4
        options.softtabstop = 4
        -- Make recipes require a literal tab; all other configured filetypes use spaces.
        options.expandtab = options.filetype ~= "make"
    end,
})

-- Keep CUDA semantic highlighting enabled explicitly.
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lyre_cuda_semantic_tokens", { clear = true }),
    callback = function(args)
        if vim.bo[args.buf].filetype == "cuda" and vim.lsp.semantic_tokens then
            vim.lsp.semantic_tokens.enable(true, { bufnr = args.buf })
        end
    end,
})

-- Re-apply transparent UI groups after changing colorschemes interactively.
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("lyre_transparent_ui", { clear = true }),
    callback = function()
        if (vim.g.colors_name or ""):find("^vira%-") then
            vim.schedule(require("config.vira").apply)
        end
    end,
})

vim.filetype.add({
    filename = {
        ["compose.yml"] = "yaml.docker-compose",
        ["compose.yaml"] = "yaml.docker-compose",
        ["docker-compose.yml"] = "yaml.docker-compose",
        ["docker-compose.yaml"] = "yaml.docker-compose",
    },
    pattern = {
        [".*/compose%..*%.yml"] = "yaml.docker-compose",
        [".*/compose%..*%.yaml"] = "yaml.docker-compose",
        [".*/docker%-compose%..*%.yml"] = "yaml.docker-compose",
        [".*/docker%-compose%..*%.yaml"] = "yaml.docker-compose",
    },
})

vim.api.nvim_create_user_command("ClearCommandHistory", function()
    vim.fn.histdel("cmd")
    local ok, error_message = pcall(vim.cmd, "wshada!")
    if not ok then
        vim.notify(
            "Command history was cleared for this session, but ShaDa could not be updated: " .. error_message,
            vim.log.levels.ERROR
        )
        return
    end
    vim.notify("Command history cleared and persisted to ShaDa", vim.log.levels.INFO)
end, {
    desc = "Clear Ex command history and persist it to ShaDa",
})
