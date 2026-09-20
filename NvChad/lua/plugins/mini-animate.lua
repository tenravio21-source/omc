return {
	"echasnovski/mini.animate",
	event = "BufReadPost",
	opts = function()
		local animate = require("mini.animate")
		return {
			open = { enable = false },
			close = { enable = false },
			scroll = {
				timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
			},
			cursor = {
				timing = animate.gen_timing.linear({ duration = 80, unit = "total" }),
			},
		}
	end,
}
