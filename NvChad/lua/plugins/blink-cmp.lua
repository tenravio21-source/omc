return {
	"saghen/blink.cmp",
	version = "v0.*",
	dependencies = {
		{ "saghen/blink.compat", opts = { enable_events = true } },
		{
			"Exafunction/codeium.nvim",
			cmd = "Codeium", -- Lazy load on command
			build = ":Codeium Auth",
			opts = {},
		},
		{
			"L3MON4D3/LuaSnip",
			build = "make install_jsregexp",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load({
					paths = vim.fn.stdpath("config") .. "/snippets",
				})
			end,
		},
	},
	opts = {
		-- Use your custom keymaps
		keymap = {
			["<C-k>"] = { "fallback" },
			["<C-b>"] = { "fallback" },
			["<C-z>"] = { "select_and_accept" },
			["<Tab>"] = {
				function(cmp)
					if cmp.is_visible() then
						return cmp.select_next()
					end
					if cmp.snippet_active() then
						return cmp.snippet_forward()
					end
					return false
				end,
				"fallback",
			},
			["<S-Tab>"] = {
				function(cmp)
					if cmp.is_visible() then
						return cmp.select_prev()
					end
					if cmp.snippet_active() then
						return cmp.snippet_backward()
					end
					return false
				end,
				"fallback",
			},
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-f>"] = { "scroll_documentation_up", "fallback" },
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },
		},

		snippets = {
			preset = "luasnip",
		},

		appearance = {
			use_nvim_cmp_as_default = true,
			kind_icons = {
				Codeium = " ",
				Text = " ",
				Method = "󰆧 ",
				Function = "󰊕 ",
				Constructor = " ",
				Field = "󰜢 ",
				Variable = "󰀫 ",
				Property = " ",
				Class = "󰌗 ",
				Interface = " ",
				Struct = "󰌗 ",
				Module = " ",
				Unit = "󰑭 ",
				Value = "󰎠 ",
				Enum = " ",
				EnumMember = " ",
				Keyword = "󰌋 ",
				Constant = "󰏿 ",
				Snippet = " ",
				Color = "󰏘 ",
				File = "󰈙 ",
				Reference = "󰈇 ",
				Folder = "󰉋 ",
				Event = " ",
				Operator = "󰆕 ",
				TypeParameter = "󰊄 ",
			},
		},

		sources = {
			default = { "lsp", "codeium", "path", "snippets", "buffer" },
			providers = {
				codeium = {
					name = "codeium",
					module = "blink.compat.source",
					score_offset = 100,
					async = true,
					transform_items = function(_, items)
						for _, item in ipairs(items) do
							item.kind = vim.lsp.protocol.CompletionItemKind.Event
							item.kind_name = "Codeium"
						end
						return items
					end,
				},
			},
		},
		cmdline = {
			keymap = {
				["<Tab>"] = { "show", "accept" },
			},
			completion = {
				menu = {
					auto_show = true,
					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind_icon", "kind", gap = 1 },
						},
					},
				},
			},
		},
		completion = {
			trigger = {
				prefetch_on_insert = false,
				show_on_trigger_character = true,
			},
			ghost_text = { enabled = true, show_without_selection = true },
			menu = {
				border = "rounded",
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind", gap = 1 },
					},
					components = {
						kind_icon = {
							ellipsis = false,
							text = function(ctx)
								return ctx.kind_icon .. ctx.icon_gap
							end,
							highlight = function(ctx)
								if ctx.item.source_name == "codeium" then
									return "BlinkCmpKindCodeium"
								end
								return "BlinkCmpKind" .. ctx.kind
							end,
						},
					},
				},
			},
			documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
		},
		signature = { enabled = true, window = { border = "rounded" } },
	},
}
