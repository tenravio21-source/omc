local util = require(".util")

local M = {}

function M.load(options)
	if not options.remember or not util.exists(options.state_file) then
		return nil
	end

	local value, err = util.read_json(options.state_file)
	if not value then
		return nil, err
	end
	if type(value.name) ~= "string" or type(value.spec) ~= "table" then
		return nil, "invalid saved pack selection"
	end
	return value
end

function M.save(options, candidate)
	if not options.remember then
		return true
	end

	local payload = {
		version = 1,
		name = candidate.name,
		label = candidate.label,
		spec = candidate.spec,
	}
	local encoded, encode_err = ya.json_encode(payload)
	if not encoded then
		return false, tostring(encode_err or "unable to encode pack selection")
	end
	return util.write_file_atomic(options.state_file, encoded .. "\n")
end

function M.clear(options)
	if not util.exists(options.state_file) then
		return true
	end
	local ok, err = os.remove(options.state_file)
	return ok == true, err
end

function M.apply(options, selected)
	if not selected then
		return options
	end
	local merged = util.deep_merge(options, {
		pack = selected.name,
		packs = { [selected.name] = selected.spec },
	})
	return merged
end

return M
