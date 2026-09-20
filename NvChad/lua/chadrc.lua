-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
	BlinkCmpGhostText = { fg = "#565f83", italic = true },
	theme = "tokyodark",

	hl_override = {
		Comment = { italic = true },
		["@comment"] = { italic = true },

		-- Functions
		["Function"] = { italic = true },
		["@function"] = { italic = true },
		["@function.builtin"] = { italic = true },
		["@function.method"] = { italic = true },

		-- Variables
		["@variable"] = { italic = true },
		["@variable.builtin"] = { italic = true },
		["@variable.parameter"] = { italic = true },
		["@variable.member"] = { italic = true }, -- Fields/Properties

		-- Classes & Types
		["Type"] = { italic = true },
		["@type"] = { italic = true },
		["@type.builtin"] = { italic = true },
		["@constructor"] = { italic = true }, -- Class constructors
		["@lsp.type.class"] = { italic = true },
	},
}

M.nvdash = {
	load_on_startup = true,
}

M.ui = {

	cmp = {
		lspkind_text = true,
		style = "default", -- default/flat_light/flat_dark/atom/atom_colored
		format_colors = {
			tailwind = false,
		},
	},

	telescope = {
		style = "bordered", -- This prevents the "floating text" look on custom layouts
	},
	statusline = {
		separator_style = "block", --  default, round, block, arrow
		theme = "minimal",
		order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor", "time" },
		modules = {
			time = function()
				local time = os.date("%H:%M")
				return "%#St_pos_sep#" .. "%#St_pos_bg#   " .. time .. " " .. "%#St_pos_sep#"
				-- return "%#St_pos_sep#" .. "%#St_pos_bg#  " .. time .. "%#St_pos_sep#"
			end,
		},
	},
	--  default, vscode, vscode_colored, minimal
	tabufline = {
		lazyload = false,
	},
}

return M
