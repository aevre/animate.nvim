local config = require("animate.config")
local easings = require("animate.easing")
local state = require("animate.state")

---@class animate.Animation
local Animation = {}
Animation.__index = Animation

---@param opts? animate.Opts
---@return animate.Animation
function Animation.new(opts)
	local id = opts and opts.id or state.next_id()
	local previous = state.get(id)
	if previous then
		previous:stop()
		state.remove(id)
	end

	local self = setmetatable({}, Animation)
	self.id = id
	self.opts = vim.tbl_deep_extend("force", config.get(), vim.deepcopy(opts or {})) --[[@as animate.Opts]]
	local easing = self.opts.easing or "linear"
	if type(easing) == "string" then
		easing = easings[easing] or easings.linear
	end
	assert(type(easing) == "function", "animate: easing must be a function or a known easing name")
	self.easing = easing
	state.add(self)
	return self
end

---@param from number
---@param to number
---@param callback animate.callback
---@return animate.Animation
function Animation:start(from, to, callback)
	self:stop()
	if from == to then
		callback(from, { animation = self, prev = from, done = true })
		return self
	end

	local duration_opts = type(self.opts.duration) == "table" and self.opts.duration or { step = self.opts.duration }
	local duration = 0
	if duration_opts.step then
		duration = duration_opts.step * math.abs(to - from)
		duration = math.min(duration, duration_opts.total or duration)
	elseif duration_opts.total then
		duration = duration_opts.total
	end
	duration = duration > 0 and duration or 250

	local step_duration = math.max(duration / math.abs(to - from), 1000 / self.opts.fps)
	local step_count = math.max(math.floor(duration / step_duration + 0.5), 10)
	local delta = 0
	if (self.opts.easing or "linear") == "linear" and self.opts.int then
		local one_step = math.max(1, math.floor(math.abs(to - from) / step_count + 0.5))
		step_count = math.floor(math.abs(to - from) / one_step + 0.5)
		delta = math.abs(to - from) - one_step * step_count
		step_duration = duration / step_count
	end

	self.steps = {}
	for i = 1, step_count do
		local value = i == step_count and to or self.easing(i, from, to - from - delta, step_count)
		if self.opts.int then
			value = math.floor(value + 0.5)
		end
		self.steps[i] = value
	end

	self._step = 0
	self.timer = state.timer()
	if not self.timer then
		return self
	end
	state.start(self.timer, step_duration, function()
		vim.schedule(function()
			self:step(callback)
		end)
	end)
	return self
end

function Animation:stop()
	state.close(self.timer)
	self.timer = nil
	self.steps, self._step = nil, nil
end

---@param callback animate.callback
function Animation:step(callback)
	if not self.steps or not self._step or self._step >= #self.steps then
		return self:stop()
	end
	self._step = self._step + 1
	local value = self.steps[self._step] --[[@as number]]
	local done = self._step >= #self.steps
	local prev = self.steps[self._step - 1] or value
	callback(value, { animation = self, prev = prev, done = done })
end

return Animation
