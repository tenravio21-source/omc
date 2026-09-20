return {
	{
		"echasnovski/mini.surround",
		keys = {
			{ "gsa", desc = "Add Surrounding", mode = { "n", "x" } },
			{ "gsd", desc = "Delete Surrounding" },
			{ "gsf", desc = "Find Right Surrounding" },
			{ "gsF", desc = "Find Left Surrounding" },
			{ "gsh", desc = "Highlight Surrounding" },
			{ "gsr", desc = "Replace Surrounding" },
			{ "gsn", desc = "Update n_lines" },
		},
		opts = {
			mappings = {
				add = "gsa", -- Add surrounding in Normal and Visual modes
				delete = "gsd", -- Delete surrounding
				find = "gsf", -- Find surrounding (to the right)
				find_left = "gsF", -- Find surrounding (to the left)
				highlight = "gsh", -- Highlight surrounding
				replace = "gsr", -- Replace surrounding
				update_n_lines = "gsn", -- Update `n_lines`
			},
		},
	},
}

--[[
Type gsaiw) (Global Surround Add Inner Word )).

    Result: word becomes (word).

Type gsr)' (Global Surround Replace ) with ').

    Result: (word) becomes 'word'.

Type gsd' (Global Surround Delete ').

    Result: 'word' returns to word.
 ]]
