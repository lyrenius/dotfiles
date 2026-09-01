return {
    {
        "mrcjkb/rustaceanvim",
        opts = function(_, opts)
            opts.server = opts.server or {}
            opts.server.default_settings = opts.server.default_settings or {}

            local rust_analyzer = opts.server.default_settings["rust-analyzer"] or {}
            rust_analyzer.files = vim.tbl_deep_extend("force", rust_analyzer.files or {}, {
                -- Let rust-analyzer watch files itself. Neovim's client-side
                -- watcher can exhaust macOS file descriptors with larger trees.
                watcher = "server",
            })
            opts.server.default_settings["rust-analyzer"] = rust_analyzer

            opts.server.handlers = opts.server.handlers or {}
            opts.server.handlers["experimental/serverStatus"] = function(err, result, ctx, config)
                local client = vim.lsp.get_client_by_id(ctx.client_id)
                local detached_files = client and vim.tbl_get(client.config, "init_options", "detachedFiles")
                local failed_to_discover = result
                    and type(result.message) == "string"
                    and result.message:find("Failed to discover workspace", 1, true)

                if detached_files and failed_to_discover then
                    -- An isolated .rs file has no Cargo workspace by design.
                    -- Keep standalone LSP features without presenting this as
                    -- a broken rust-analyzer installation.
                    result = vim.tbl_extend("force", result, {
                        health = "ok",
                        message = nil,
                    })
                end

                return require("rustaceanvim.server_status").handler(err, result, ctx, config)
            end
        end,
    },
}
