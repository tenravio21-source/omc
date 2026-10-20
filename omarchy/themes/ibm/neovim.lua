return {
    {
        "bjarneo/aether.nvim",
        branch = "v2",
        name = "aether",
        priority = 1000,
        opts = {
            transparent = false,
            colors = {
                -- Background colors
                bg = "#050709",
                bg_dark = "#050709",
                bg_highlight = "#4a4a4a",

                -- Foreground colors
                -- fg: Object properties, builtin types, builtin variables, member access, default text
                fg = "#ffffff",
                -- fg_dark: Inactive elements, statusline, secondary text
                fg_dark = "#993426",
                -- comment: Line highlight, gutter elements, disabled states
                comment = "#4a4a4a",

                -- Accent colors
                -- red: Errors, diagnostics, tags, deletions, breakpoints
                red = "#66a773",
                -- orange: Constants, numbers, current line number, git modifications
                orange = "#a3cfa8",
                -- yellow: Types, classes, constructors, warnings, numbers, booleans
                yellow = "#b4b47b",
                -- green: Comments, strings, success states, git additions
                green = "#d24646",
                -- cyan: Parameters, regex, preprocessor, hints, properties
                cyan = "#a360a3",
                -- blue: Functions, keywords, directories, links, info diagnostics
                blue = "#727272",
                -- purple: Storage keywords, special keywords, identifiers, namespaces
                purple = "#8686ba",
                -- magenta: Function declarations, exception handling, tags
                magenta = "#afafd2",
            },
        },
        config = function(_, opts)
            require("aether").setup(opts)
            vim.cmd.colorscheme("aether")

            -- Enable hot reload
            require("aether.hotreload").setup()
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "aether",
        },
    },
}
