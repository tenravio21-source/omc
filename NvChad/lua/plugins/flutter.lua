return {
	"nvim-flutter/flutter-tools.nvim",
	ft = { "dart" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"stevearc/dressing.nvim",
	},
	-- Mappings grouped under <leader>F
	keys = {
		{ "<leader>Ff", "<cmd>FlutterRun<CR>", desc = "Flutter Run" },
		{ "<leader>Fq", "<cmd>FlutterQuit<CR>", desc = "Flutter Quit" },
		{ "<leader>Fr", "<cmd>FlutterReload<CR>", desc = "Flutter Hot Reload" },
		{ "<leader>FR", "<cmd>FlutterRestart<CR>", desc = "Flutter Hot Restart" },
		{ "<leader>Fd", "<cmd>FlutterDevices<CR>", desc = "Flutter Devices" },
		{ "<leader>Fe", "<cmd>FlutterEmulators<CR>", desc = "Flutter Emulators" },
		{ "<leader>Fc", "<cmd>FlutterToggleDeviceLog<CR>", desc = "Flutter Toggle Device Log" },
		{ "<leader>Fo", "<cmd>FlutterOutlineToggle<CR>", desc = "Flutter Outline Toggle" },
	},
	config = function()
		require("flutter-tools").setup({
			ui = {
				border = "rounded",
				notification_style = "native",
			},
			decorations = {
				statusline = {
					app_version = false,
					device = true,
				},
			},
			widget_guides = {
				enabled = true,
			},
			closing_tags = {
				highlight = "ErrorMsg",
				prefix = "//",
				enabled = true,
			},
			lsp = {
				color = {
					enabled = true,
					background = false,
					foreground = false,
					virtual_text = true,
					virtual_text_str = "■",
				},
				settings = {
					showTodos = true,
					completeFunctionCalls = true,
					enableSnippets = true,
				},
			},
		})
	end,
}
