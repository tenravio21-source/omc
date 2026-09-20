local util = require(".util")

local M = {}

M.defaults = {
	pack = "builtin",
	packs = {},
	overrides = {
		files = {},
		extensions = {},
		folders = {},
		definitions = {},
	},
	backend = "auto",
	size = {
		cols = 2,
		rows = 1,
		pixels = 64,
	},
	fallback = true,
	remember = true,
	discovery_roots = {
		"~/.vscode/extensions",
		"~/.vscode-oss/extensions",
		"~/.vscodium/extensions",
		"~/.cursor/extensions",
		"~/.windsurf/extensions",
	},
	plugin_dir = util.join(util.config_dir(), "plugins/real-icons.yazi"),
	cache_dir = util.join(util.cache_home(), "real-icons/yazi"),
	data_dir = util.join(util.data_home(), "real-icons"),
	state_file = util.join(util.state_home(), "real-icons/yazi-pack.json"),
}

M.options = util.deep_merge(M.defaults, {})

local function validate(options)
	local size = options.size
	size.cols = math.floor(tonumber(size.cols) or 2)
	size.rows = math.floor(tonumber(size.rows) or 1)
	size.pixels = math.floor(tonumber(size.pixels) or 64)

	assert(size.cols >= 1 and size.cols <= 3, "real-icons size.cols must be between 1 and 3")
	assert(size.rows == 1, "real-icons currently supports size.rows = 1")
	assert(size.pixels >= 16 and size.pixels <= 256, "real-icons size.pixels must be between 16 and 256")
	assert(type(options.pack) == "string" and options.pack ~= "", "real-icons pack must be a string")
	assert(type(options.packs) == "table", "real-icons packs must be a table")
	assert(type(options.overrides) == "table", "real-icons overrides must be a table")
	assert(type(options.discovery_roots) == "table", "real-icons discovery_roots must be a table")
	assert(type(options.remember) == "boolean", "real-icons remember must be a boolean")

	options.plugin_dir = util.expand(options.plugin_dir)
	options.cache_dir = util.expand(options.cache_dir)
	options.data_dir = util.expand(options.data_dir)
	options.state_file = util.expand(options.state_file)
	for index, root in ipairs(options.discovery_roots) do
		options.discovery_roots[index] = util.expand(root)
	end
	return options
end

function M.setup(options)
	M.options = validate(util.deep_merge(M.defaults, options or {}))
	return M.options
end

return M
