return {
    {
        "stevearc/conform.nvim",
        opts = function(_, opts)
            opts.formatters_by_ft = opts.formatters_by_ft or {}
            opts.formatters_by_ft.c = { "clang_format" }
            opts.formatters_by_ft.cpp = { "clang_format" }
            opts.formatters_by_ft.cuda = { "clang_format" }
            opts.formatters_by_ft.python = { "black" }
            opts.formatters_by_ft.lua = { "stylua" }
            opts.formatters_by_ft.markdown = {}
            opts.formatters_by_ft["markdown.mdx"] = {}
            opts.formatters_by_ft.sh = { "shfmt" }
            opts.formatters_by_ft.zsh = { "shfmt" }

            opts.formatters = opts.formatters or {}
            opts.formatters.clang_format = {
                prepend_args = {
                    "--style={BasedOnStyle: Google, UseTab: Never, IndentWidth: 4, NamespaceIndentation: All, FixNamespaceComments: false, SortIncludes: true}",
                },
            }
            opts.formatters.stylua = {
                prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
            }
            opts.formatters.shfmt = {
                prepend_args = { "-i", "4", "-ci" },
            }
        end,
    },
    {
        "mason-org/mason.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            for _, tool in ipairs({ "black", "clang-format", "shfmt", "stylua" }) do
                if not vim.tbl_contains(opts.ensure_installed, tool) then
                    table.insert(opts.ensure_installed, tool)
                end
            end

            local unique = {}
            local seen = {}
            local excluded = {
                ["markdownlint-cli2"] = true,
                ["markdown-toc"] = true,
            }
            for _, tool in ipairs(opts.ensure_installed) do
                if not excluded[tool] and not seen[tool] then
                    seen[tool] = true
                    table.insert(unique, tool)
                end
            end
            opts.ensure_installed = unique
        end,
    },
    {
        "mfussenegger/nvim-lint",
        opts = function(_, opts)
            opts.linters_by_ft = opts.linters_by_ft or {}
            opts.linters_by_ft.markdown = {}
        end,
    },
}
