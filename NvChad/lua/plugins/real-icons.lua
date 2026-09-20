return {
	"Mirsmog/real-icons.nvim",
	build = ":RealIcons install",
	lazy = false,
	opts = {
		pack = "material",
		integrations = {
			nvim_tree = true,
			telescope = true,
		},
	},
}
