---@class animate
---@overload fun(from: number, to: number, callback: animate.callback, opts?: animate.Opts): animate.Animation
local M = setmetatable({}, {
	__call = function(t, ...)
		return t.add(...)
	end,
})

---@alias animate.easing.Fn fun(time: number, begin: number, change: number, duration: number): number

---@class animate.Duration
---@field step? number duration step in ms
---@field total? number total duration in ms

---@class animate.Config
---@field duration? animate.Duration|number
---@field easing? string|animate.easing.Fn
---@field fps? number
local defaults = {
	duration = 20,
	easing = "linear",
	fps = 120,
}

---@type animate.Config
local config = {}

---@param opts? animate.Config
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	return M
end

local uv = vim.uv
local _id = 0

local function next_id()
	_id = _id + 1
	return _id
end

---@class animate.Ctx
---@field done boolean
---@field animation animate.Animation
---@field prev number

---@alias animate.callback fun(value: number, ctx: animate.Ctx)

---@class animate.Opts: animate.Config
---@field buf? number
---@field int? boolean 将值平整为整数
---@field id? number|string

---@type table<number|string, animate.Animation>
local active = setmetatable({}, { __mode = "v" })

---@class animate.Animation
---@field id number|string
---@field easing animate.easing.Fn
---@field opts animate.Opts
---@field timer? uv.uv_timer_t
---@field steps? number[]
---@field _step? number
local Animation = {}
Animation.__index = Animation

---@param opts? animate.Opts
function Animation.new(opts)
	local id = opts and opts.id or next_id()

	if active[id] ~= nil then
		active[id]:stop()
		active[id] = nil
	end

	local self = setmetatable({}, Animation)
	self.id = id

	self.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), vim.deepcopy(config), opts or {}) --[[@as animate.Opts]]
	local easing = self.opts.easing or "linear"
	if type(easing) == "string" then
		local easings = require("animate.easing")
		easing = easings[easing] or easings.linear
	end
	assert(type(easing) == "function", "animate: easing must be a function or a known easing name")
	self.easing = easing
	active[id] = self

	return self
end

---@param from number
---@param to number
---@param callback animate.callback
function Animation:start(from, to, callback)
	self:stop()
	if from == to then
		callback(from, { animation = self, prev = from, done = true })
		return self
	end

	local opt_duration = type(self.opts.duration) == "table" and self.opts.duration or { step = self.opts.duration }

	local duration = 0 --[[@as number]]
	if opt_duration.step then
		duration = opt_duration.step * math.abs(to - from)
		duration = math.min(duration, opt_duration.total or duration)
	elseif opt_duration.total then
		duration = opt_duration.total
	end

	duration = duration or 250

	local step_duration = math.max(duration / math.abs(to - from), 1000 / self.opts.fps)
	local step_count = math.max(math.floor(duration / step_duration + 0.5), 10)

	local delta = 0 --[[@as number]]
	if (self.opts.easing or "linear") == "linear" and self.opts.int then
		local one_step = math.max(1, math.floor(math.abs(to - from) / step_count + 0.5))
		step_count = math.floor(math.abs(to - from) / one_step + 0.5)
		delta = math.abs(to - from) - one_step * step_count
		step_duration = duration / step_count
	end

	self.steps = {}
	for i = 1, step_count do
		local value = 0 --[[@as number]]
		if i == step_count then
			value = to
		else
			value = self.easing(i, from, to - from - delta, step_count)
		end
		if self.opts.int then
			value = math.floor(value + 0.5)
		end
		table.insert(self.steps, value)
	end

	self._step = 0
	active[self.id] = self
	self.timer = uv.new_timer()
	if self.timer == nil then
		return
	end
	self.timer:start(0, step_duration --[[@as integer]], function()
		vim.schedule(function()
			self:step(callback)
		end)
	end)
	return self
end

function Animation:stop()
	if self.timer then
		self.timer:stop()
		self.timer:close()
		self.timer = nil
	end
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

function M.enabled(opts)
	opts = opts or {}
	if opts.name and not M.enabled({ buf = opts.buf }) then
		return false
	end
	local key = "core_animate" .. (opts.name and ("_" .. opts.name) or "")
	local ok, value = pcall(function()
		return vim.b[opts.buf or 0][key]
	end)
	if ok and value ~= nil then
		return value
	end
	return vim.g[key] ~= false
end

function M.del(id)
	if active[id] then
		active[id]:stop()
		active[id] = nil
	end
end

---@param from number
---@param to number
---@param callback animate.callback
---@param opts? animate.Opts
function M.add(from, to, callback, opts)
	return Animation.new(opts):start(from, to, callback)
end

return M
