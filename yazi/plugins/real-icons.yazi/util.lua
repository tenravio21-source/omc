local M = {}

local function clone(value)
	if type(value) ~= "table" then
		return value
	end

	local result = {}
	for key, item in pairs(value) do
		result[clone(key)] = clone(item)
	end
	return result
end

function M.deep_merge(base, override)
	local result = clone(base)
	for key, value in pairs(override or {}) do
		if type(value) == "table" and type(result[key]) == "table" then
			result[key] = M.deep_merge(result[key], value)
		else
			result[key] = clone(value)
		end
	end
	return result
end

function M.expand(path)
	path = tostring(path or "")
	if path == "~" or path:sub(1, 2) == "~/" then
		local home = os.getenv("HOME") or os.getenv("USERPROFILE") or ""
		path = home .. path:sub(2)
	end
	return M.normalize(path)
end

function M.normalize(path)
	path = tostring(path or ""):gsub("\\", "/")
	local absolute = path:sub(1, 1) == "/"
	local drive = path:match("^(%a:)/")
	local parts = {}

	for part in path:gmatch("[^/]+") do
		if part == ".." then
			if #parts > 0 and parts[#parts] ~= ".." then
				table.remove(parts)
			elseif not absolute then
				parts[#parts + 1] = part
			end
		elseif part ~= "." and part ~= "" and part ~= drive then
			parts[#parts + 1] = part
		end
	end

	local prefix = drive and (drive .. "/") or (absolute and "/" or "")
	local result = prefix .. table.concat(parts, "/")
	return result ~= "" and result or (absolute and "/" or ".")
end

function M.join(root, path)
	path = tostring(path or "")
	if path:sub(1, 1) == "/" or path:match("^%a:[/\\]") then
		return M.normalize(path)
	end
	return M.normalize(tostring(root or "") .. "/" .. path)
end

function M.dirname(path)
	path = M.normalize(path)
	return path:match("^(.*)/[^/]*$") or "."
end

function M.basename(path)
	return M.normalize(path):match("([^/]+)$") or ""
end

function M.extension(path)
	return M.basename(path):match("%.([^.]+)$")
end

function M.is_within(root, path)
	root, path = M.normalize(root), M.normalize(path)
	return path == root or path:sub(1, #root + 1) == root:gsub("/$", "") .. "/"
end

function M.exists(path)
	local handle = io.open(path, "rb")
	if not handle then
		return false
	end
	handle:close()
	return true
end

function M.read_file(path)
	local handle, err = io.open(path, "rb")
	if not handle then
		return nil, err or ("unable to read " .. tostring(path))
	end
	local content = handle:read("*a")
	handle:close()
	return content
end

function M.write_file_atomic(path, content)
	path = M.expand(path)
	local parent = M.dirname(path)
	local ok, mkdir_err = M.mkdir_p(parent)
	if not ok then
		return false, "unable to create " .. parent .. ": " .. tostring(mkdir_err)
	end

	local temporary = path .. ".tmp-" .. M.hash(path .. tostring(os.time()))
	local handle, open_err = io.open(temporary, "wb")
	if not handle then
		return false, open_err or ("unable to write " .. temporary)
	end

	local wrote, write_err = handle:write(tostring(content or ""))
	local closed, close_err = handle:close()
	if not wrote or not closed then
		os.remove(temporary)
		return false, write_err or close_err or ("unable to write " .. temporary)
	end

	local moved, move_err = os.rename(temporary, path)
	if not moved then
		os.remove(temporary)
		return false, move_err or ("unable to replace " .. path)
	end
	return true
end

function M.read_json(path)
	local content, err = M.read_file(path)
	if not content then
		return nil, err
	end
	local value, decode_err = ya.json_decode(content)
	if not value then
		return nil, tostring(decode_err or ("unable to parse " .. path))
	end
	return value
end

function M.shell_quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

function M.mkdir_p(path)
	path = M.expand(path)
	if path == "" or path == "." or path == "/" then
		return false, "unsafe directory path: " .. path
	end
	local ok = os.execute("mkdir -p -- " .. M.shell_quote(path))
	return ok == true or ok == 0, ok
end

function M.hash(value)
	local a, b = 5381, 52711
	value = tostring(value or "")
	for index = 1, #value do
		local byte = value:byte(index)
		a = (a * 33 + byte) % 16777216
		b = (b * 65599 + byte) % 16777216
	end
	return string.format("%06x%06x", a, b)
end

function M.slug(value)
	local result = tostring(value or ""):lower():gsub("[^%w._-]+", "-")
	result = result:gsub("^-+", ""):gsub("-+$", "")
	return result ~= "" and result or "pack"
end

function M.config_dir()
	local explicit = os.getenv("YAZI_CONFIG_HOME")
	if explicit and explicit ~= "" then
		return M.expand(explicit)
	end
	local xdg = os.getenv("XDG_CONFIG_HOME")
	if xdg and xdg ~= "" then
		return M.join(xdg, "yazi")
	end
	return M.expand("~/.config/yazi")
end

function M.cache_home()
	local xdg = os.getenv("XDG_CACHE_HOME")
	return xdg and xdg ~= "" and M.expand(xdg) or M.expand("~/.cache")
end

function M.data_home()
	local xdg = os.getenv("XDG_DATA_HOME")
	return xdg and xdg ~= "" and M.expand(xdg) or M.expand("~/.local/share")
end

function M.state_home()
	local xdg = os.getenv("XDG_STATE_HOME")
	return xdg and xdg ~= "" and M.expand(xdg) or M.expand("~/.local/state")
end

return M
