return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown", "codecompanion" },
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
	opts = {
		heading = { position = "inline", width = "block" },
		latex = { enabled = false }, -- Good call for speed
		checkbox = {
			checked = { icon = "✔ ", scope_highlight = "@markup.strikethrough" },
			unchecked = { icon = "✘ " },
			custom = {
				important = {
					raw = "[~]",
					rendered = "󰓎 ",
					highlight = "DiagnosticWarn",
				},
			},
		},
		-- Use 'language' style but ensure it doesn't trigger heavy re-renders
		code = { style = "language", width = "block", left_pad = 2 },
		pipe_table = { preset = "round" },
		link = {
			email = " ",
			custom = {
				python = { pattern = "%.py$", icon = "󰌠 " },
			},
		},
		-- 0.11 Optimization: Ensure it uses the fastest winbar/overlay method
		render_modes = { "n", "c" },
	},
}
