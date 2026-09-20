local packs = require(".pack")
local util = require(".util")

local M = {}

local function count(tbl)
	local result = 0
	for _ in pairs(tbl or {}) do
		result = result + 1
	end
	return result
end

local function sample_keys(tbl, limit)
	local result = {}
	for key in pairs(tbl or {}) do
		result[#result + 1] = tostring(key)
	end
	table.sort(result)
	while #result > limit do
		table.remove(result)
	end
	return result
end

local function signature(spec)
	if (spec.type or "simple") == "builtin" then
		return "builtin"
	end
	local root = util.expand(spec.path or "")
	local selector = (spec.theme or spec.id) and ("theme:" .. tostring(spec.theme or spec.id))
		or ("manifest:" .. tostring(spec.manifest or ""))
	return table.concat({ spec.type or "simple", root, selector }, "|")
end

local function enrich(options, candidate)
	local selected = util.deep_merge(options, {
		pack = candidate.name,
		packs = { [candidate.name] = candidate.spec },
	})
	local icon_pack, err = packs.load(selected)
	if not icon_pack then
		candidate.error = tostring(err)
		return candidate
	end

	candidate.stats = {
		definitions = count(icon_pack.definitions),
		extensions = count(icon_pack.file_extensions),
		files = count(icon_pack.file_names),
		folders = count(icon_pack.folder_names),
	}
	candidate.samples = sample_keys(icon_pack.file_extensions, 8)
	return candidate
end

local function configured(options)
	local result = {
		{
			name = "builtin",
			label = "Builtin",
			extension = "real-icons.yazi",
			source = "Bundled",
			spec = { type = "builtin" },
		},
	}

	local names = {}
	for name in pairs(options.packs or {}) do
		if name ~= "builtin" then
			names[#names + 1] = name
		end
	end
	table.sort(names)
	for _, name in ipairs(names) do
		local spec = options.packs[name]
		result[#result + 1] = {
			name = name,
			label = spec.label or name,
			extension = spec.type == "vscode" and "VS Code theme" or "Local pack",
			source = "Configured",
			spec = spec,
		}
	end
	return result
end

local function package_files(root)
	local output, err = Command("find")
		:arg({ root, "-mindepth", "2", "-maxdepth", "2", "-name", "package.json", "-type", "f" })
		:output()
	if err or not output or not output.status.success then
		return {}
	end

	local result = {}
	for path in output.stdout:gmatch("[^\r\n]+") do
		result[#result + 1] = path
	end
	table.sort(result)
	return result
end

local function discovered(options)
	local result = {}
	for _, root in ipairs(options.discovery_roots or {}) do
		for _, package_file in ipairs(package_files(root)) do
			local package = util.read_json(package_file)
			local themes = package and package.contributes and package.contributes.iconThemes or {}
			local extension_root = util.dirname(package_file)
			for _, theme in ipairs(themes) do
				if type(theme.path) == "string" then
					local extension = package.displayName or package.name or util.basename(extension_root)
					local label = theme.label or theme.id or "Icon theme"
					local stable = extension_root .. "|" .. tostring(theme.id or theme.path)
					result[#result + 1] = {
						name = "vscode-" .. util.slug(extension) .. "-" .. util.slug(theme.id or label) .. "-" .. util.hash(stable):sub(1, 6),
						label = label,
						extension = extension,
						source = "Discovered",
						manifest = theme.path,
						spec = {
							type = "vscode",
							path = extension_root,
							theme = theme.id,
							manifest = theme.path,
						},
					}
				end
			end
		end
	end
	return result
end

function M.scan(options)
	local result = configured(options)
	local seen = {}
	for index, candidate in ipairs(result) do
		seen[signature(candidate.spec)] = index
	end

	for _, candidate in ipairs(discovered(options)) do
		local key = signature(candidate.spec)
		local existing = seen[key]
		if existing then
			local current = result[existing]
			current.label = candidate.label
			current.extension = candidate.extension
			current.manifest = candidate.manifest
		else
			seen[key] = #result + 1
			result[#result + 1] = candidate
		end
	end

	for _, candidate in ipairs(result) do
		enrich(options, candidate)
	end
	table.sort(result, function(a, b)
		if a.name == "builtin" then
			return true
		elseif b.name == "builtin" then
			return false
		end
		local left = (a.extension or "") .. "\0" .. (a.label or "")
		local right = (b.extension or "") .. "\0" .. (b.label or "")
		return left:lower() < right:lower()
	end)
	return result
end

return M
