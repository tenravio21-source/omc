return {
	"folke/todo-comments.nvim",
	cmd = { "TodoTrouble", "TodoTelescope" },
	keys = {
		{ "<leader>I", "<cmd>TodoTelescope<cr>", desc = "Todo Telescope" },
		{
			"]t",
			function()
				require("todo-comments").jump_next()
			end,
			desc = "Next Todo",
		},
		{
			"[t",
			function()
				require("todo-comments").jump_prev()
			end,
			desc = "Prev Todo",
		},
	},
	opts = {
		highlight = {
			keyword = "wide", -- "wide" is visual, but very fast in 0.11
			after = "fg",
			pattern = [[.*<(KEYWORDS)\s*:]],
		},
		keywords = {
			FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "ISSUE" } },
			TODO = { icon = " ", color = "info" },
			WARNING = { icon = " ", color = "warning", alt = { "WARN", "CAUTION" } },
			PERF = { icon = "󰅒", color = "hint", alt = { "PERFORMANCE", "OPTIMIZE" } },
			NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
			TEST = { icon = "󰙨 ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			HACK = { icon = " ", color = "warning" },
		},
		search = {
			command = "rg", -- ripgrep is the fastest way to handle this
			args = {
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case", -- Added for better search speed/accuracy
			},
		},
	},
}
