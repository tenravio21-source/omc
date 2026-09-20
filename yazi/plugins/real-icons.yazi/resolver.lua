local util = require(".util")

local M = {}

local pack
local options
local cache = {}
local cache_size = 0
local CACHE_LIMIT = 8192

local function value_key(value)
	if type(value) == "table" then
		return value.icon or value.name
	end
	return value
end

local function override_source(value)
	value = value_key(value)
	if not value then
		return nil, nil
	end
	local definitions = options.overrides.definitions or {}
	if definitions[value] then
		return value, util.expand(definitions[value])
	end
	if type(value) == "string" and (value:find("/", 1, true) or value:match("%.[%w]+$")) then
		return "override-" .. util.hash(value), util.expand(value)
	end
	return value, nil
end

local function resolve_key(path, name, lower_name, extension, is_dir)
	local overrides = options.overrides
	local key, source

	if is_dir then
		key, source = override_source((overrides.folders or overrides.folder_names or {})[lower_name])
		key = key or value_key(pack.folder_names[lower_name]) or value_key(pack.folder_names[name])
		key = key or value_key(pack.folder)
	else
		key, source = override_source((overrides.files or overrides.file_names or {})[lower_name])
		if not key then
			key, source = override_source((overrides.extensions or overrides.file_extensions or {})[extension])
		end
		key = key or value_key(pack.file_names[lower_name]) or value_key(pack.file_names[name])
		key = key or value_key(pack.file_extensions[extension])
		key = key or value_key(pack.file)
	end

	return key, source or (key and pack.definitions[key])
end

function M.setup(new_pack, new_options)
	pack, options = new_pack, new_options
	M.clear()
end

function M.resolve(file)
	if not pack or not file or not file.url then
		return nil
	end

	local path = tostring(file.url)
	local is_dir = file.cha and file.cha.is_dir == true
	local cache_key = (is_dir and "d:" or "f:") .. path
	if cache[cache_key] ~= nil then
		return cache[cache_key] or nil
	end

	local name = file.name or util.basename(path)
	local lower_name = name:lower()
	local extension = (file.url.ext and tostring(file.url.ext) or util.extension(name) or ""):lower()
	local key, source = resolve_key(path, name, lower_name, extension, is_dir)
	local icon = source and {
		key = key,
		pack = pack.name,
		path = path,
		source = source,
		is_dir = is_dir,
	} or false

	if cache_size >= CACHE_LIMIT then
		M.clear()
	end
	cache[cache_key] = icon
	cache_size = cache_size + 1
	return icon or nil
end

function M.clear()
	cache = {}
	cache_size = 0
end

return M
