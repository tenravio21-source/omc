local M = {
	keys = {
		{ on = "q", run = "quit" },
		{ on = "<Esc>", run = "quit" },
		{ on = "<Enter>", run = "select" },
		{ on = "l", run = "select" },
		{ on = "j", run = "down" },
		{ on = "<Down>", run = "down" },
		{ on = "k", run = "up" },
		{ on = "<Up>", run = "up" },
		{ on = "g", run = "first" },
		{ on = "G", run = "last" },
	},
}

local function mirror_picker(picker)
	M.candidates = picker.candidates
	M.current = picker.current
	M.cursor = picker.cursor
	M.child = picker.child
end

local show = ya.sync(function(state, candidates, current)
	local picker = state.real_icons_picker or {}
	state.real_icons_picker = picker
	picker.candidates = candidates
	picker.current = current
	picker.cursor = 0
	for index, candidate in ipairs(candidates) do
		if candidate.name == current then
			picker.cursor = index - 1
			break
		end
	end
	mirror_picker(picker)
	if not picker.child then
		picker.child = Modal:children_add(M, 10)
	end
	mirror_picker(picker)
	ui.render()
end)

local hide = ya.sync(function(state)
	local picker = state.real_icons_picker or {}
	if picker.child then
		Modal:children_remove(picker.child)
		picker.child = nil
	end
	mirror_picker(picker)
	ui.render()
end)

local move = ya.sync(function(state, action)
	local picker = state.real_icons_picker or {}
	local last = math.max(0, #(picker.candidates or {}) - 1)
	if action == "up" then
		picker.cursor = math.max(0, (picker.cursor or 0) - 1)
	elseif action == "down" then
		picker.cursor = math.min(last, (picker.cursor or 0) + 1)
	elseif action == "first" then
		picker.cursor = 0
	elseif action == "last" then
		picker.cursor = last
	end
	mirror_picker(picker)
	ui.render()
end)

local active = ya.sync(function(state)
	local picker = state.real_icons_picker or {}
	return picker.candidates and picker.candidates[(picker.cursor or 0) + 1] or nil
end)

function M:new(area)
	self:layout(area)
	return self
end

function M:layout(area)
	local vertical = ui.Layout()
		:constraints({
			ui.Constraint.Percentage(8),
			ui.Constraint.Percentage(84),
			ui.Constraint.Percentage(8),
		})
		:split(area)
	local horizontal = ui.Layout()
		:direction(ui.Layout.HORIZONTAL)
		:constraints({
			ui.Constraint.Percentage(7),
			ui.Constraint.Percentage(40),
			ui.Constraint.Percentage(46),
			ui.Constraint.Percentage(7),
		})
		:split(vertical[2])
	self._area = ui.Rect {
		x = horizontal[2].x,
		y = horizontal[2].y,
		w = horizontal[2].w + horizontal[3].w,
		h = horizontal[2].h,
	}
	local columns = ui.Layout()
		:direction(ui.Layout.HORIZONTAL)
		:constraints({ ui.Constraint.Percentage(46), ui.Constraint.Percentage(54) })
		:split(self._area:pad(ui.Pad(2, 1, 2, 1)))
	self._list = columns[1]:pad(ui.Pad(0, 1, 0, 1))
	self._details = columns[2]:pad(ui.Pad(0, 1, 0, 2))
end

function M:reflow()
	return { self }
end

local function detail_lines(candidate)
	if not candidate then
		return { "No icon packs found." }
	end

	local stats = candidate.stats or {}
	local lines = {
		ui.Line(candidate.label or candidate.name):style(ui.Style():fg("cyan"):bold()),
		"",
		ui.Line { ui.Span("Extension  "):bold(), candidate.extension or "Unknown" },
		ui.Line { ui.Span("Source     "):bold(), candidate.source or "Unknown" },
		ui.Line { ui.Span("Type       "):bold(), candidate.spec.type or "simple" },
	}
	if candidate.spec.theme then
		lines[#lines + 1] = ui.Line { ui.Span("Theme      "):bold(), tostring(candidate.spec.theme) }
	end
	if candidate.spec.path then
		lines[#lines + 1] = ""
		lines[#lines + 1] = ui.Line("Path"):style(ui.Style():bold())
		lines[#lines + 1] = tostring(candidate.spec.path)
	end
	lines[#lines + 1] = ""
	if candidate.error then
		lines[#lines + 1] = ui.Line("Unavailable"):style(ui.Style():fg("red"):bold())
		lines[#lines + 1] = candidate.error
	else
		lines[#lines + 1] = ui.Line("Coverage"):style(ui.Style():bold())
		lines[#lines + 1] = string.format(
			"%d definitions, %d extensions",
			stats.definitions or 0,
			stats.extensions or 0
		)
		lines[#lines + 1] = string.format("%d file names, %d folders", stats.files or 0, stats.folders or 0)
	end
	if candidate.samples and #candidate.samples > 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = ui.Line {
			ui.Span("Examples  "):bold(),
			table.concat(candidate.samples, "  "),
		}
	end
	return lines
end

function M:redraw()
	local rows = {}
	for _, candidate in ipairs(self.candidates or {}) do
		local marker = candidate.name == self.current and "●" or " "
		rows[#rows + 1] = ui.Row { marker, candidate.label or candidate.name }
	end
	local selected = self.candidates and self.candidates[(self.cursor or 0) + 1] or nil

	return {
		ui.Clear(self._area),
		ui.Border(ui.Edge.ALL)
			:area(self._area)
			:type(ui.Border.ROUNDED)
			:style(ui.Style():fg("blue"))
			:title(ui.Line("Real Icons: packs"):align(ui.Align.CENTER)),
		ui.Border(ui.Edge.RIGHT):area(self._list):style(ui.Style():fg("darkgray")),
		ui.Table(rows)
			:area(self._list:pad(ui.Pad(0, 1, 0, 0)))
			:row(self.cursor)
			:row_style(ui.Style():fg("cyan"):bold())
			:widths({ ui.Constraint.Length(2), ui.Constraint.Percentage(100) }),
		ui.Text(detail_lines(selected)):area(self._details):wrap(ui.Wrap.YES),
		ui.Text("j/k move   Enter select   q close")
			:area(ui.Rect { x = self._area.x + 2, y = self._area.bottom - 2, w = self._area.w - 4, h = 1 })
			:align(ui.Align.CENTER)
			:style(ui.Style():fg("darkgray")),
	}
end

function M.open(candidates, current)
	show(candidates, current)
	while true do
		local index = ya.which { cands = M.keys, silent = true }
		local candidate = M.keys[index]
		local action = candidate and candidate.run or "quit"
		if action == "quit" then
			hide()
			return nil
		elseif action == "select" then
			local selected = active()
			hide()
			return selected
		else
			move(action)
		end
	end
end

return M
