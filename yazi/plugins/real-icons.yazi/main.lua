--- @since 26.1.22

local cache = require(".cache")
local config = require(".config")
local discovery = require(".discovery")
local kitty = require(".kitty")
local packs = require(".pack")
local picker = require(".picker")
local resolver = require(".resolver")
local store = require(".state")
local util = require(".util")

local M = {}
local runtime = {
	enabled = false,
	patched = false,
	subscribed = false,
}

local get_options = ya.sync(function(state)
	return state.options or {}
end)

local apply_runtime = ya.sync(function(state, options, icon_pack)
	local ok, err = cache.setup(options, icon_pack.name)
	if not ok then
		return false, err
	end
	state.options = options
	runtime.options = options
	runtime.pack = icon_pack
	runtime.error = nil
	resolver.setup(icon_pack, options)
	kitty.clear_uploaded()
	local terminal = kitty.setup(options)
	runtime.enabled = terminal.supported
	ui.render()
	return true
end)

local function notify(level, content, timeout)
	ya.notify {
		title = "Real Icons",
		content = tostring(content),
		level = level,
		timeout = timeout or 5,
	}
end

local function fallback_icon(entity)
	if runtime.options and runtime.options.fallback == false then
		return ""
	end
	return runtime.original_icon and runtime.original_icon(entity) or ""
end

local function render_icon(entity)
	if not runtime.enabled or not kitty.supported() then
		return fallback_icon(entity)
	end

	local icon = resolver.resolve(entity._file)
	if not icon then
		return fallback_icon(entity)
	end

	local path = cache.render_path(icon)
	if not path then
		return fallback_icon(entity)
	end

	local segment = kitty.segment(path, runtime.options.size)
	if not segment then
		return fallback_icon(entity)
	end

	return ui.Line {
		ui.Span(segment.text):fg(segment.fg),
		" ",
	}
end

local function patch_entity()
	if runtime.patched then
		return
	end
	runtime.original_icon = Entity._real_icons_original_icon or Entity.icon
	Entity._real_icons_original_icon = runtime.original_icon
	Entity.icon = render_icon
	Entity._real_icons_patched = true
	runtime.patched = true
end

local function subscribe()
	if runtime.subscribed then
		return
	end
	ps.sub("real-icons-ready", function()
		ui.render()
	end)
	ps.sub("real-icons-reload", function()
		resolver.clear()
		kitty.clear_uploaded()
		ui.render()
	end)
	runtime.subscribed = true
end

local function load_runtime(options)
	local icon_pack, err = packs.load(options)
	if not icon_pack then
		local fallback_options = util.deep_merge(options, { pack = "builtin" })
		icon_pack = assert(packs.load(fallback_options))
		notify("warn", tostring(err) .. "; using builtin pack", 7)
	end

	local ok, cache_err = cache.setup(options, icon_pack.name)
	if not ok then
		return nil, cache_err
	end
	resolver.setup(icon_pack, options)
	return icon_pack
end

function M.setup(state, options)
	local configured = config.setup(options)
	local selected, state_err = store.load(configured)
	if selected then
		local candidate_options = config.setup(store.apply(configured, selected))
		local candidate_pack, candidate_err = packs.load(candidate_options)
		if candidate_pack then
			configured = candidate_options
		else
			notify("warn", "Saved pack is unavailable: " .. tostring(candidate_err), 7)
		end
	elseif state_err then
		notify("warn", "Cannot read saved pack: " .. tostring(state_err), 7)
	end

	state.options = configured
	runtime.options = configured
	runtime.pack, runtime.error = load_runtime(runtime.options)
	local terminal = kitty.setup(runtime.options)
	runtime.enabled = runtime.pack ~= nil and runtime.error == nil and terminal.supported

	patch_entity()
	subscribe()

	if runtime.error then
		notify("error", runtime.error, 7)
	elseif not terminal.supported then
		notify("warn", terminal.reason or "unsupported terminal; using Yazi icons", 7)
	end
end

local function isolated_runtime()
	local options = config.setup(get_options())
	local icon_pack, err = packs.load(options)
	if not icon_pack then
		return nil, nil, err
	end
	local ok, cache_err = cache.setup(options, icon_pack.name)
	if not ok then
		return nil, nil, cache_err
	end
	kitty.setup(options)
	return options, icon_pack
end

local function doctor()
	local options, icon_pack, err = isolated_runtime()
	if not options then
		return notify("error", err, 8)
	end
	local terminal = kitty.detect()
	local cache_stats = cache.stats()
	local content = table.concat({
		"pack: " .. icon_pack.name,
		"definitions: " .. #packs.sources(icon_pack),
		"terminal: " .. tostring(terminal.terminal),
		"tmux: " .. tostring(terminal.tmux == true),
		"supported: " .. tostring(terminal.supported == true),
		"cache: " .. cache_stats.directory,
	}, "\n")
	notify(terminal.supported and "info" or "warn", content, 10)
end

local function build_cache()
	local _, icon_pack, err = isolated_runtime()
	if not icon_pack then
		return notify("error", err, 8)
	end
	local sources = packs.sources(icon_pack)
	notify("info", "Building " .. #sources .. " icon variants", 3)
	local complete, failed = cache.build(sources)
	notify(failed == 0 and "info" or "warn", string.format("Cache ready: %d, failed: %d", complete, failed), 8)
	Command("ya"):arg({ "pub", "real-icons-reload" }):status()
end

local function clear_cache()
	local options = config.setup(get_options())
	local ok, err = cache.setup(options, options.pack)
	if not ok then
		return notify("error", err, 8)
	end
	ok, err = cache.clear()
	if not ok then
		return notify("error", err, 8)
	end
	notify("info", "Generated icon cache cleared", 5)
	Command("ya"):arg({ "pub", "real-icons-reload" }):status()
end

local function choose_pack()
	local options = config.setup(get_options())
	local candidates = discovery.scan(options)
	if #candidates == 0 then
		return notify("warn", "No icon packs found", 6)
	end

	local selected = picker.open(candidates, options.pack)
	if not selected then
		return
	end
	if selected.error then
		return notify("error", selected.error, 8)
	end

	local selected_options = config.setup(util.deep_merge(options, {
		pack = selected.name,
		packs = { [selected.name] = selected.spec },
	}))
	local icon_pack, load_err = packs.load(selected_options)
	if not icon_pack then
		return notify("error", load_err, 8)
	end

	local saved, save_err = store.save(selected_options, selected)
	if not saved then
		return notify("error", "Cannot save pack selection: " .. tostring(save_err), 8)
	end
	local applied, apply_err = apply_runtime(selected_options, icon_pack)
	if not applied then
		return notify("error", "Cannot apply pack: " .. tostring(apply_err), 8)
	end
	notify("info", "Icon pack: " .. (selected.label or selected.name), 4)
end

function M.entry(_, job)
	job = type(job) == "string" and { args = { job } } or (job or { args = {} })
	local action = job.args and job.args[1] or "doctor"
	if action == "doctor" then
		return doctor()
	elseif action == "packs" then
		return choose_pack()
	elseif action == "build-cache" or action == "build" then
		return build_cache()
	elseif action == "clear-cache" or action == "clear" then
		return clear_cache()
	else
		notify("warn", "Unknown action: " .. tostring(action), 5)
	end
end

return M
