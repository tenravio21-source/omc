return {
	"nvim-telescope/telescope.nvim",
	opts = function()
		local actions = require("telescope.actions")
		return {
			defaults = {
				mappings = {
					i = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
						["<C-n>"] = actions.cycle_history_next,
						["<C-p>"] = actions.cycle_history_prev,
						["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
						["<C-l>"] = actions.complete_tag,
						["<C-_>"] = actions.which_key,
						["<C-w>"] = { "<c-s-w>", type = "command" },
						["<C-h>"] = "which_key",
						["<esc>"] = actions.close,
					},
					n = {
						["q"] = actions.close,
						["<C-n>"] = actions.move_selection_next,
						["<C-p>"] = actions.move_selection_previous,
						["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
						["<C-c>"] = actions.close,
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
						["<C-h>"] = "which_key",
					},
				},
				border = true,
				borderchars = {
					prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
					results = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
					preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				},
				initial_mode = "insert",
				prompt_prefix = "   ",
				selection_caret = "  ",
				path_display = { "truncate" },
				sorting_strategy = "ascending",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.70,
					},
					width = 0.87,
					height = 0.80,
				},
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
					"--glob",
					"!{.git,node_modules,.DS_Store}",
				},
				file_ignore_patterns = {
					"node_modules",
					".git/",
					".DS_Store",
					"dist/",
					"build/",
				},
			},
			pickers = {
				buffers = { sort_lastused = true },
			},
		}
	end,
}
