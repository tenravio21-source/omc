return {
	"folke/which-key.nvim",
	opts = {
		timeout = 500,
		win = {
			border = "rounded",
			padding = { 1, 2, 1, 2 },
		},
		layout = {
			align = "center",
		},
		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "+",
		},
		plugins = {
			marks = true,
			registers = true,
			spelling = {
				enabled = true,
				suggestions = 20,
			},
		},
		spec = {
			{ "<leader>c", group = "Cheatsheet", icon = "󰚩 " },
			{ "<leader>f", group = "Finder", icon = "󰍉 " },
			{ "<leader>F", group = "Flutter", icon = "󱓞 " },
			{ "<leader>g", group = "Git", icon = "󰊢 " },
			{ "<leader>p", group = "Packages", icon = "󰏖 " },
			{ "<leader>u", group = "Interface", icon = "󰙵 " },
			{ "<leader>w", group = "Workspace/LSP", icon = "󱔗 " },
			{ "<leader>d", group = "Debug/Diagnostics", icon = "󰒓 " },
			{ "<leader>t", group = "Appearance", icon = "󰏘 " },
			{ "<leader>m", group = "Marks", icon = "󰀱 " },
			{ "<leader>r", group = "Refactor", icon = "󰑕 " },
			{ "<leader>s", group = "Search/Flash", icon = "󱗘 " },
			{ "<leader>z", group = "LeetCode", icon = "󰛠 " },
		},
	},
}
