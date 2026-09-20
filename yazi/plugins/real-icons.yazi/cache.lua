local util = require(".util")

local M = {}

local options
local pack_dir
local ready = {}
local pending = {}
local source_valid = {}

local CONVERT_SCRIPT = [=[
set -eu
source_path=$1
temporary_path=$2
target_path=$3
pixel_size=$4
extension=$5
notify=$6

if [ "$extension" = "svg" ] && command -v resvg >/dev/null 2>&1; then
	resvg -w "$pixel_size" -h "$pixel_size" "$source_path" "$temporary_path"
elif command -v magick >/dev/null 2>&1; then
	magick -limit thread 1 -background none "$source_path" -alpha on \
		-filter Lanczos -resize "${pixel_size}x${pixel_size}" \
		-gravity center -background none -extent "${pixel_size}x${pixel_size}" \
		-strip "PNG:$temporary_path"
else
	exit 127
fi

mv -f -- "$temporary_path" "$target_path"
if [ "$notify" = "1" ] && command -v ya >/dev/null 2>&1; then
	ya pub real-icons-ready --str "$target_path" >/dev/null 2>&1 || true
fi
]=]

local function target(icon)
	local key = util.slug(icon.key or util.basename(icon.source))
	local hash = util.hash(icon.source .. "\0" .. tostring(options.size.pixels))
	return util.join(pack_dir, key .. "-" .. hash .. ".png")
end

local function extension(source)
	return (util.extension(source) or ""):lower()
end

local function spawn_conversion(icon, destination)
	local existing = pending[destination]
	if existing and os.time() - existing.started < 15 then
		return
	end
	pending[destination] = nil

	local temporary = destination .. ".tmp-" .. util.hash(icon.source .. tostring(os.time()))
	local child, err = Command("sh"):arg({
		"-c",
		CONVERT_SCRIPT,
		"real-icons",
		icon.source,
		temporary,
		destination,
		tostring(options.size.pixels),
		extension(icon.source),
		"1",
	}):spawn()
	if child then
		pending[destination] = { child = child, started = os.time() }
	else
		pending[destination] = { error = tostring(err), started = os.time() }
	end
end

function M.setup(new_options, pack_name)
	options = new_options
	pack_dir = util.join(options.cache_dir, util.slug(pack_name) .. "/" .. options.size.pixels .. "px")
	local ok, err = util.mkdir_p(pack_dir)
	if not ok then
		return false, "unable to create icon cache: " .. tostring(err)
	end
	ready = {}
	pending = {}
	source_valid = {}
	return true
end

function M.render_path(icon)
	if not icon or not icon.source then
		return nil, "icon source does not exist"
	end
	if source_valid[icon.source] == nil then
		source_valid[icon.source] = util.exists(icon.source)
	end
	if not source_valid[icon.source] then
		return nil, "icon source does not exist"
	end

	local ext = extension(icon.source)
	if ext == "png" then
		return icon.source
	end
	if ext ~= "svg" and ext ~= "jpg" and ext ~= "jpeg" and ext ~= "webp" then
		return nil, "unsupported icon format: " .. ext
	end

	local destination = target(icon)
	if ready[destination] or util.exists(destination) then
		ready[destination] = true
		pending[destination] = nil
		return destination
	end

	spawn_conversion(icon, destination)
	return nil, "icon conversion scheduled"
end

function M.build(icons)
	local complete, failed = 0, 0
	local seen = {}
	for _, icon in ipairs(icons or {}) do
		if not seen[icon.source] then
			seen[icon.source] = true
			local ext = extension(icon.source)
			if ext == "png" then
				complete = complete + 1
			elseif ext == "svg" or ext == "jpg" or ext == "jpeg" or ext == "webp" then
				local destination = target(icon)
				if util.exists(destination) then
					complete = complete + 1
				else
					local temporary = destination .. ".tmp-build"
					local status = Command("sh"):arg({
						"-c",
						CONVERT_SCRIPT,
						"real-icons",
						icon.source,
						temporary,
						destination,
						tostring(options.size.pixels),
						ext,
						"0",
					}):status()
					if status and status.success then
						ready[destination] = true
						complete = complete + 1
					else
						failed = failed + 1
					end
				end
			else
				failed = failed + 1
			end
		end
	end
	return complete, failed
end

function M.clear()
	if not options.cache_dir:find("real%-icons") or #options.cache_dir < 10 then
		return false, "refusing to clear unsafe cache path"
	end
	local status, err = Command("sh"):arg({
		"-c",
		"find \"$1\" -mindepth 1 -type f -delete",
		"real-icons",
		options.cache_dir,
	}):status()
	if not status or not status.success then
		return false, tostring(err or "cache cleanup failed")
	end
	ready = {}
	pending = {}
	source_valid = {}
	return true
end

function M.stats()
	local ready_count, pending_count = 0, 0
	for _ in pairs(ready) do
		ready_count = ready_count + 1
	end
	for _ in pairs(pending) do
		pending_count = pending_count + 1
	end
	return { ready = ready_count, pending = pending_count, directory = pack_dir }
end

return M
