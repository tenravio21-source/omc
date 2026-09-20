hl.config({
	-- https://wiki.hyprland.org/Configuring/Variables/#general
	general = {
		gaps_in = 3,
		gaps_out = 9,
		border_size = 1,

		-- Change to niri-like side-scrolling layout
		layout = "scrolling",
	},

	-- https://wiki.hyprland.org/Configuring/Variables/#decoration
	decoration = {
		-- Use round window corners
		rounding = 10,

		-- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed)
		dim_inactive = true,
		dim_strength = 0.2,
	},

	-- https://wiki.hyprland.org/Configuring/Variables/#animations
	animations = {
		enabled = true,
		bezier = {
			myBezier = { 0.10, 0.9, 0.1, 1.05 },
		},
		animation = {
			"windows, 1, 5, myBezier, slide",
			"windowsOut, 1, 5, myBezier, slide",
			"border, 1, 10, default",
			"fade, 1, 7, default",
			"workspaces, 1, 6, default",
		},
	},
})
