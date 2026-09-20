return {
	"folke/trouble.nvim",
	cmd = { "Trouble" },
	opts = {
		focus = true,
		auto_close = true,
		position = "bottom",
		padding = 2,
		win = { border = "rounded" },
		modes = {
			lsp = {
				win = { position = "right" },
			},
		},
		icons = {
			-- Hardcoded icons prevent loading an external icons module during boot
			indent = {
				top = "│ ",
				middle = "├─ ",
				last = "└─ ",
				fold_open = " ",
				fold_closed = " ",
			},
		},
	},
	keys = {
		{ "<leader>dw", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics" },
		{ "<leader>dd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document Diagnostics" },
		{ "<leader>dq", "<cmd>Trouble quickfix toggle<cr>", desc = "Quickfix List" },
		{ "<leader>dl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
		{ "<leader>dt", "<cmd>Trouble todo toggle<cr>", desc = "Todo Comments" },
		{
			"[q",
			function()
				if require("trouble").is_open() then
					require("trouble").prev({ skip_groups = true, jump = true })
				else
					pcall(vim.cmd.cprev)
				end
			end,
			desc = "Previous Trouble/Quickfix Item",
		},
		{
			"]q",
			function()
				if require("trouble").is_open() then
					require("trouble").next({ skip_groups = true, jump = true })
				else
					pcall(vim.cmd.cnext)
				end
			end,
			desc = "Next Trouble/Quickfix Item",
		},
	},
}
