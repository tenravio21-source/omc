return {
	"kawre/leetcode.nvim",
	cmd = { "Leet" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	keys = {
		-- Core Actions
		{ "<leader>zz", "<cmd>Leet<cr>", desc = "LeetCode Dashboard" },
		{ "<leader>zc", "<cmd>Leet exit<cr>", desc = "Exit LeetCode" },
		{ "<leader>zl", "<cmd>Leet list<cr>", desc = "Search Problems" },

		-- Execution
		{ "<leader>zr", "<cmd>Leet run<cr>", desc = "Run Solution" },
		{ "<leader>zs", "<cmd>Leet submit<cr>", desc = "Submit Solution" },
		{ "<leader>zv", "<cmd>Leet console<cr>", desc = "Toggle Console" },

		-- Views & Info
		{ "<leader>zi", "<cmd>Leet info<cr>", desc = "Problem Info" },
		{ "<leader>zh", "<cmd>Leet desc<cr>", desc = "Toggle Description" },
		{ "<leader>zt", "<cmd>Leet tabs<cr>", desc = "List Tabs" },

		-- Discovery
		{ "<leader>zd", "<cmd>Leet daily<cr>", desc = "Daily Challenge" },
		{ "<leader>zx", "<cmd>Leet random<cr>", desc = "Random Problem" },

		-- Code Utilities
		{ "<leader>zu", "<cmd>Leet last_submit<cr>", desc = "Restore Last Submit" },
		{ "<leader>zR", "<cmd>Leet reset<cr>", desc = "Reset Snippet" },
		{ "<leader>zg", "<cmd>Leet lang<cr>", desc = "Change Language" },
	},
	opts = {
		lang = "dart",
	},
}
