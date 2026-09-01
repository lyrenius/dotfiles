local vira = require("config.vira")
local p = vira.palette
local c = vira.colors

return {
    {
        "nvim-mini/mini.base16",
        version = "*",
        lazy = false,
        priority = 1000,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "vira-graphene",
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        opts = function(_, opts)
            opts.options.theme = vira.lualine_theme()
        end,
    },
    {
        "akinsho/bufferline.nvim",
        opts = function(_, opts)
            opts.highlights = opts.highlights or {}

            local transparent = {
                "fill",
                "background",
                "buffer_visible",
                "buffer_selected",
                "close_button",
                "close_button_visible",
                "close_button_selected",
                "duplicate",
                "duplicate_visible",
                "duplicate_selected",
                "numbers",
                "numbers_visible",
                "numbers_selected",
                "diagnostic",
                "diagnostic_visible",
                "diagnostic_selected",
                "hint",
                "hint_visible",
                "hint_selected",
                "info",
                "info_visible",
                "info_selected",
                "warning",
                "warning_visible",
                "warning_selected",
                "error",
                "error_visible",
                "error_selected",
                "modified",
                "modified_visible",
                "modified_selected",
                "pick",
                "pick_visible",
                "pick_selected",
                "separator",
                "separator_visible",
                "separator_selected",
                "indicator_selected",
                "offset_separator",
                "tab",
                "tab_selected",
                "tab_separator",
                "tab_separator_selected",
                "trunc_marker",
            }

            for _, name in ipairs(transparent) do
                opts.highlights[name] = vim.tbl_deep_extend("force", opts.highlights[name] or {}, { bg = "NONE" })
            end

            opts.highlights.fill.fg = p.base03
            opts.highlights.background.fg = p.base04
            opts.highlights.buffer_visible.fg = p.base05
            opts.highlights.buffer_selected.fg = p.base07
            opts.highlights.buffer_selected.bold = true
            opts.highlights.buffer_selected.italic = true
            opts.highlights.indicator_selected.fg = c.accent
            opts.highlights.separator.fg = p.base02
            opts.highlights.separator_visible.fg = p.base02
            opts.highlights.separator_selected.fg = p.base02
        end,
    },
    {
        "folke/snacks.nvim",
        opts = {
            dashboard = { enabled = false },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = function(_, opts)
            opts.heading = opts.heading or {}
            opts.heading.backgrounds = {
                "RenderMarkdownH1",
                "RenderMarkdownH2",
                "RenderMarkdownH3",
                "RenderMarkdownH4",
                "RenderMarkdownH5",
                "RenderMarkdownH6",
            }
        end,
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = {
            default_component_configs = {
                diagnostics = {
                    symbols = {
                        hint = "·",
                        info = "i",
                        warn = "!",
                        error = "x",
                    },
                },
                git_status = {
                    symbols = {
                        added = "+",
                        deleted = "-",
                        modified = "~",
                        renamed = ">",
                        untracked = "?",
                        ignored = "·",
                        unstaged = "M",
                        staged = "S",
                        conflict = "!",
                    },
                },
            },
            filesystem = {
                group_empty_dirs = false,
                filtered_items = {
                    visible = true,
                },
            },
        },
    },
}
