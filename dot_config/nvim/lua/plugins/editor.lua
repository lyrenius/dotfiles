return {
    {
        "saghen/blink.cmp",
        opts = function(_, opts)
            opts.keymap = opts.keymap or {}
            opts.keymap.preset = "enter"
            opts.keymap["<CR>"] = { "fallback" }
            opts.keymap["<C-y>"] = { "select_and_accept" }
            opts.keymap["<Tab>"] = {
                "select_and_accept",
                LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }),
                "fallback",
            }

            opts.completion = opts.completion or {}
            opts.completion.list = opts.completion.list or {}
            opts.completion.list.selection = {
                preselect = false,
                auto_insert = false,
            }
        end,
    },
    {
        "L3MON4D3/LuaSnip",
        build = false,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            if vim.env.CHEZMOI_BOOTSTRAP == "1" then
                opts.ensure_installed = {}
                return
            end

            opts.ensure_installed = opts.ensure_installed or {}
            for _, parser in ipairs({
                "cmake",
                "cpp",
                "cuda",
                "diff",
                "dockerfile",
                "dtd",
                "git_config",
                "git_rebase",
                "gitattributes",
                "gitcommit",
                "gitignore",
                "gotmpl",
                "helm",
                "ini",
                "make",
                "nginx",
                "requirements",
                "rust",
                "ssh_config",
                "toml",
                "xml",
                "yaml",
                "zsh",
            }) do
                if not vim.tbl_contains(opts.ensure_installed, parser) then
                    table.insert(opts.ensure_installed, parser)
                end
            end
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
                virtual_text = false,
                virtual_lines = {
                    current_line = true,
                },
                severity_sort = true,
                float = {
                    border = "rounded",
                    source = "if_many",
                    header = "",
                    prefix = "",
                },
            })

            opts.servers = opts.servers or {}

            local clangd = opts.servers.clangd or {}
            clangd.filetypes = { "c", "cpp", "objc", "objcpp", "cuda" }
            clangd.cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=never",
                "--completion-style=detailed",
                "--function-arg-placeholders=true",
                "--fallback-style=Google",
            }
            clangd.init_options = vim.tbl_deep_extend("force", clangd.init_options or {}, {
                fallbackFlags = { "-std=c++20" },
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
            })
            opts.servers.clangd = clangd

            local pyright = opts.servers.pyright or {}
            pyright.settings = vim.tbl_deep_extend("force", pyright.settings or {}, {
                python = {
                    analysis = {
                        typeCheckingMode = "standard",
                        autoImportCompletions = true,
                    },
                },
            })
            opts.servers.pyright = pyright

            -- VS Code uses Pylance plus Black; keep Ruff out of the LSP/formatter path.
            opts.servers.ruff = { enabled = false }
            opts.servers.ruff_lsp = { enabled = false }

            local yamlls = opts.servers.yamlls or {}
            yamlls.filetypes = { "yaml", "yaml.gitlab" }
            yamlls.settings = vim.tbl_deep_extend("force", yamlls.settings or {}, {
                yaml = {
                    format = {
                        enable = true,
                        tabWidth = 4,
                    },
                },
            })
            opts.servers.yamlls = yamlls
        end,
    },
    {
        "iamcco/markdown-preview.nvim",
        enabled = function()
            return vim.fn.executable("node") == 1
        end,
    },
    {
        "mechatroner/rainbow_csv",
        ft = { "csv", "tsv", "csv_semicolon", "csv_whitespace" },
    },
}
