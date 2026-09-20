local util = require(".util")

local M = {}

local function icon_key(value)
	if type(value) == "table" then
		return value.icon or value.name
	end
	return value
end

local function builtin(options)
	local assets = util.join(options.plugin_dir, "assets")
	return {
		name = "builtin",
		definitions = {
			file = util.join(assets, "file.png"),
			folder = util.join(assets, "folder.png"),
			git = util.join(assets, "git.png"),
			javascript = util.join(assets, "javascript.png"),
			json = util.join(assets, "json.png"),
			lua = util.join(assets, "lua.png"),
			markdown = util.join(assets, "markdown.png"),
			rust = util.join(assets, "rust.png"),
			text = util.join(assets, "text.png"),
			typescript = util.join(assets, "typescript.png"),
			["folder-git"] = util.join(assets, "folder-git.png"),
			["folder-node-modules"] = util.join(assets, "folder-node-modules.png"),
			["folder-src"] = util.join(assets, "folder-src.png"),
			["folder-test"] = util.join(assets, "folder-test.png"),
		},
		file = "file",
		folder = "folder",
		file_extensions = {
			git = "git",
			js = "javascript",
			jsx = "javascript",
			json = "json",
			lua = "lua",
			md = "markdown",
			mdx = "markdown",
			rs = "rust",
			text = "text",
			txt = "text",
			ts = "typescript",
			tsx = "typescript",
		},
		file_names = {
			[".gitattributes"] = "git",
			[".gitignore"] = "git",
			[".gitmodules"] = "git",
			["license"] = "markdown",
			["license.md"] = "markdown",
			["package.json"] = "json",
			["readme"] = "markdown",
			["readme.md"] = "markdown",
		},
		folder_names = {
			[".git"] = "folder-git",
			["node_modules"] = "folder-node-modules",
			source = "folder-src",
			src = "folder-src",
			test = "folder-test",
			tests = "folder-test",
		},
	}
end

local function resolve_asset(root, base, path)
	local result = util.join(base, path)
	if not util.is_within(root, result) then
		return nil, "icon path escapes pack root: " .. tostring(path)
	end
	return result
end

local function select_manifest(root, spec)
	if spec.manifest then
		return resolve_asset(root, root, spec.manifest)
	end

	local package, err = util.read_json(util.join(root, "package.json"))
	if not package then
		return nil, err
	end

	local themes = package.contributes and package.contributes.iconThemes or {}
	if #themes == 0 then
		return nil, "VS Code extension has no icon themes"
	end

	local requested = spec.theme or spec.id
	local selected = themes[1]
	if requested then
		selected = nil
		for _, theme in ipairs(themes) do
			if theme.id == requested or theme.label == requested then
				selected = theme
				break
			end
		end
	end

	if not selected then
		return nil, "icon theme not found: " .. tostring(requested)
	end
	return resolve_asset(root, root, selected.path)
end

local function vscode(name, spec)
	local root = util.expand(assert(spec.path, "VS Code pack requires path"))
	local manifest_file, manifest_err = select_manifest(root, spec)
	if not manifest_file then
		return nil, manifest_err
	end

	local manifest, err = util.read_json(manifest_file)
	if not manifest then
		return nil, err
	end

	local definitions = {}
	local base = util.dirname(manifest_file)
	for key, definition in pairs(manifest.iconDefinitions or {}) do
		if definition.iconPath then
			local path, path_err = resolve_asset(root, base, definition.iconPath)
			if not path then
				return nil, path_err
			end
			definitions[key] = path
		end
	end

	return {
		name = name,
		root = root,
		manifest = manifest_file,
		definitions = definitions,
		file = icon_key(manifest.file),
		folder = icon_key(manifest.folder),
		file_extensions = manifest.fileExtensions or {},
		file_names = manifest.fileNames or {},
		folder_names = manifest.folderNames or {},
		language_ids = manifest.languageIds or {},
	}
end

local function add_simple_asset(root, definitions, value)
	value = icon_key(value)
	if type(value) ~= "string" then
		return nil
	end
	if value:find("/", 1, true) or value:match("%.[%w]+$") then
		local key = "asset-" .. util.hash(value)
		definitions[key] = util.join(root, value)
		return key
	end
	return value
end

local function simple_map(root, definitions, input)
	local output = {}
	for key, value in pairs(input or {}) do
		output[key] = add_simple_asset(root, definitions, value)
	end
	return output
end

local function simple(name, spec)
	local root = util.expand(assert(spec.path, "simple pack requires path"))
	local definitions = {}
	for key, value in pairs(spec.definitions or {}) do
		definitions[key] = util.join(root, value)
	end

	local file = add_simple_asset(root, definitions, spec.file or "file.png")
	local folder = add_simple_asset(root, definitions, spec.folder or "folder.png")
	return {
		name = name,
		root = root,
		definitions = definitions,
		file = file,
		folder = folder,
		file_extensions = simple_map(root, definitions, spec.extensions or spec.file_extensions),
		file_names = simple_map(root, definitions, spec.files or spec.file_names),
		folder_names = simple_map(root, definitions, spec.folders or spec.folder_names),
		language_ids = simple_map(root, definitions, spec.languages or spec.language_ids),
	}
end

local function normalize(name, pack)
	pack.name = pack.name or name
	pack.definitions = pack.definitions or {}
	pack.file_extensions = pack.file_extensions or {}
	pack.file_names = pack.file_names or {}
	pack.folder_names = pack.folder_names or {}
	pack.language_ids = pack.language_ids or {}
	return pack
end

function M.load(options)
	local name = options.pack
	if name == "builtin" then
		return normalize(name, builtin(options))
	end

	local spec = options.packs[name]
	if not spec then
		return nil, "unknown icon pack: " .. name
	end

	local loader = spec.type or "simple"
	local pack, err
	if loader == "vscode" then
		pack, err = vscode(name, spec)
	elseif loader == "simple" then
		pack, err = simple(name, spec)
	else
		return nil, "unknown pack type: " .. tostring(loader)
	end
	return pack and normalize(name, pack) or nil, err
end

function M.sources(pack)
	local result, seen = {}, {}
	for key, source in pairs(pack.definitions or {}) do
		if type(source) == "string" and not seen[source] then
			seen[source] = true
			result[#result + 1] = { key = key, pack = pack.name, source = source }
		end
	end
	table.sort(result, function(a, b) return a.source < b.source end)
	return result
end

return M
