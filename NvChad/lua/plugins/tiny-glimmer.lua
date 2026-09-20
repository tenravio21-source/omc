return {
	"rachartier/tiny-glimmer.nvim",
	event = "TextYankPost",
	opts = {
		enabled = true,
		autoreload = true,
		animations = {
			fade = {
				from_color = "DiffAdd",
				to_color = "CursorLine",
			},
			reverse_fade = {
				from_color = "DiffAdd",
				to_color = "CursorLine",
			},
		},
		overwrite = {
			auto_map = true,
			undo = { enabled = true },
			redo = { enabled = true },
			search = {
				enabled = true,
				default_animation = "pulse",
			},
		},
	},
}
