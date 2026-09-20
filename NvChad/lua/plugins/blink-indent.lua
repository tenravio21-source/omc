return {
	"saghen/blink.indent",
	version = "*",
	dependencies = { "saghen/blink.download" },
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		blocked = {
			buftypes = { include_defaults = true },
			filetypes = {
				include_defaults = true,
				"NvimTree",
				"Trouble",
				"trouble",
				"neo-tree",
				"lazy",
				"mason",
				"notify",
				"toggleterm",
				"lazyterm",
			},
		},
		scope = {
			enabled = true,
			char = "▎",
			highlights = { "BlinkIndentGreen", "BlinkIndentViolet", "BlinkIndentBlue" },
		},
	},
}
