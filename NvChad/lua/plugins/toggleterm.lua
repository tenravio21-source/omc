return {
	"akinsho/toggleterm.nvim",
	cmd = { "ToggleTerm", "TermExec" },
	keys = {
		{ "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
		{ "<esc><esc>", "<C-\\><C-n><cmd>ToggleTerm<cr>", mode = "t", desc = "Exit Terminal" },
	},
	opts = {
		size = 20,
		open_mapping = [[<c-\>]], -- Keep the default toggle shortcut
		hide_numbers = true,
		shade_terminals = false, -- Disabling shading saves some window redraw cycles
		start_in_insert = true,
		insert_mappings = true,
		persist_size = true,
		direction = "float",
		close_on_exit = true,
		shell = "nu",
		float_opts = {
			border = "rounded",
			winblend = 0,
		},
		highlights = {
			NormalFloat = {
				link = "NormalFloat", -- Matches the theme's floating background
			},
			FloatBorder = {
				link = "FloatBorder", -- Matches the theme's border color
			},
		},
	},
}
