return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre", -- uncomment for format on save
		opts = require("configs.conform"),
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		enabled = false,
	},

	{ "nvim-tree/nvim-web-devicons", enabled = false },

	{
		"williamboman/mason.nvim",
		opts = {
			ui = {
				border = "rounded",
				-- icons = {
				-- 	package_pending = " ",
				-- 	package_installed = "󰄲 ",
				-- 	package_uninstalled = " 󰚌 ",
				-- },
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			require("configs.lspconfig")
		end,
	},

	{ import = "nvchad.blink.lazyspec" },

	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		opts = function(_, opts)
			return opts
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"vim",
				"html",
				"lua",
				"vimdoc",
				"dart",
				"rust",
				"python",
			},
			highlight = {
				enable = true,
				use_languagetree = true,
			},
			indent = { enable = true },
		},
	},
}
