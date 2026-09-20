local util = require(".util")

local M = {}

local ESC = string.char(27)
local PLACEHOLDER = utf8.char(0x10eeee)
local DIACRITICS = {
	utf8.char(0x0305),
	utf8.char(0x030d),
	utf8.char(0x030e),
}
local IMAGE_ID_BASE = 0x520000
local IMAGE_ID_RANGE = 0x0fffff

local options
local detection
local uploaded_by_id = {}
local uploaded_by_path = {}

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64(value)
	local result = {}
	local index = 1
	while index <= #value do
		local a = value:byte(index) or 0
		local b = value:byte(index + 1) or 0
		local c = value:byte(index + 2) or 0
		local triple = a * 65536 + b * 256 + c

		result[#result + 1] = b64chars:sub(math.floor(triple / 262144) % 64 + 1, math.floor(triple / 262144) % 64 + 1)
		result[#result + 1] = b64chars:sub(math.floor(triple / 4096) % 64 + 1, math.floor(triple / 4096) % 64 + 1)
		result[#result + 1] = index + 1 <= #value
			and b64chars:sub(math.floor(triple / 64) % 64 + 1, math.floor(triple / 64) % 64 + 1)
			or "="
		result[#result + 1] = index + 2 <= #value
			and b64chars:sub(triple % 64 + 1, triple % 64 + 1)
			or "="
		index = index + 3
	end
	return table.concat(result)
end

local function in_tmux()
	local value = os.getenv("TMUX")
	return value ~= nil and value ~= ""
end

local function tmux_client_term()
	if not in_tmux() then
		return nil
	end
	local handle = io.popen("tmux display-message -p '#{client_termname}' 2>/dev/null", "r")
	if not handle then
		return nil
	end
	local value = handle:read("*l")
	handle:close()
	return value and value:lower() or nil
end

local function wrap_tmux(command)
	if not in_tmux() then
		return command
	end
	return ESC .. "Ptmux;" .. command:gsub(ESC, ESC .. ESC) .. ESC .. "\\"
end

local function send(command)
	command = wrap_tmux(command)
	local stream = io.stderr or io.stdout
	stream:write(command)
	stream:flush()
end

local function command(control, payload)
	return ESC .. "_G" .. control .. ";" .. (payload or "") .. ESC .. "\\"
end

local function detect()
	if detection then
		return detection
	end

	local backend = tostring(options.backend or "auto"):lower()
	if backend == "disabled" or backend == "none" or backend == "off" then
		detection = { supported = false, terminal = "disabled", reason = "backend disabled" }
		return detection
	end
	if os.getenv("NO_COLOR") ~= nil then
		detection = {
			supported = false,
			terminal = "no-color",
			reason = "NO_COLOR removes the RGB image ID from Kitty placeholders",
		}
		return detection
	end

	local term_program = (os.getenv("TERM_PROGRAM") or ""):lower()
	local term = (os.getenv("TERM") or ""):lower()
	local client = tmux_client_term() or ""
	local ghostty = term_program:find("ghostty", 1, true)
		or client:find("ghostty", 1, true)
		or os.getenv("GHOSTTY_RESOURCES_DIR")
		or os.getenv("GHOSTTY_BIN_DIR")
	local kitty = term_program:find("kitty", 1, true)
		or term:find("kitty", 1, true)
		or client:find("kitty", 1, true)
		or os.getenv("KITTY_WINDOW_ID")
	local forced = backend == "kitty" or backend == "force"

	detection = {
		supported = forced or ghostty ~= nil or kitty ~= nil,
		terminal = ghostty and "ghostty" or (kitty and "kitty" or (forced and "forced" or "unsupported")),
		tmux = in_tmux(),
		tmux_client_term = client ~= "" and client or nil,
	}
	if not detection.supported then
		detection.reason = "Kitty Unicode placeholders are not supported by this terminal"
	end
	return detection
end

local function allocate_id(path)
	if uploaded_by_path[path] then
		return uploaded_by_path[path]
	end

	local id = IMAGE_ID_BASE + (tonumber(util.hash(path):sub(1, 6), 16) % IMAGE_ID_RANGE)
	local first = id
	repeat
		local owner = uploaded_by_id[id]
		if not owner or owner == path then
			return id
		end
		id = IMAGE_ID_BASE + ((id - IMAGE_ID_BASE + 1) % IMAGE_ID_RANGE)
	until id == first
	return nil
end

function M.setup(new_options)
	options = new_options
	detection = nil
	return detect()
end

function M.detect()
	return detect()
end

function M.supported()
	return detect().supported
end

function M.upload(path, cols, rows)
	if not M.supported() then
		return nil, detection.reason
	end
	if uploaded_by_path[path] then
		return uploaded_by_path[path]
	end

	local id = allocate_id(path)
	if not id then
		return nil, "no Kitty image IDs are available"
	end

	local control = table.concat({
		"a=T",
		"f=100",
		"t=f",
		"q=2",
		"U=1",
		"i=" .. id,
		"c=" .. cols,
		"r=" .. rows,
	}, ",")
	send(command(control, base64(path)))
	uploaded_by_id[id] = path
	uploaded_by_path[path] = id
	return id
end

function M.placeholder(cols, rows)
	assert(rows == 1, "real-icons currently supports one placeholder row")
	local cells = {}
	for column = 1, cols do
		cells[#cells + 1] = PLACEHOLDER .. DIACRITICS[1] .. DIACRITICS[column]
	end
	return table.concat(cells)
end

function M.segment(path, size)
	local id, err = M.upload(path, size.cols, size.rows)
	if not id then
		return nil, err
	end
	return {
		text = M.placeholder(size.cols, size.rows),
		fg = string.format("#%06x", id),
		width = size.cols,
		image_id = id,
	}
end

function M.clear_uploaded()
	local commands = {}
	for id in pairs(uploaded_by_id) do
		commands[#commands + 1] = command("a=d,d=I,q=2,i=" .. id)
	end
	if #commands > 0 then
		send(table.concat(commands))
	end
	uploaded_by_id = {}
	uploaded_by_path = {}
end

function M.stats()
	local count = 0
	for _ in pairs(uploaded_by_id) do
		count = count + 1
	end
	return { uploaded = count, detection = detect() }
end

return M
