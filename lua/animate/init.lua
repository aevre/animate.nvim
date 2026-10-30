---@class animate
---@overload fun(from: number, to: number, callback: animate.callback, opts?: animate.Opts): animate.Animation
---@type animate
local M = setmetatable({}, {
	__call = function(t, ...)
		return t.add(...)
	end,
})

local Config = require("animate.config")
local Animation = require("animate.animation")
local state = require("animate.state")

---@param opts? animate.Config
---@return animate
function M.setup(opts)
	Config.setup(opts)
	return M
end

---@param opts? { name?: string, buf?: number }
---@return boolean
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

---@param id number|string
function M.del(id)
	local animation = state.get(id)
	if animation then
		animation:stop()
		state.remove(id)
	end
end

---@param from number
---@param to number
---@param callback animate.callback
---@param opts? animate.Opts
---@return animate.Animation
function M.add(from, to, callback, opts)
	return Animation.new(opts):start(from, to, callback)
end

M.Animation = Animation
M.easing = require("animate.easing")

return M
