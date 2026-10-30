---@class animate.State
local M = {}

local uv = vim.uv
local id = 0
---@type table<number|string, animate.Animation>
local active = setmetatable({}, { __mode = "v" })

---@return integer
function M.next_id()
	id = id + 1
	return id
end

---@param key number|string
---@return animate.Animation?
function M.get(key)
	return active[key]
end

---@param animation animate.Animation
function M.add(animation)
	active[animation.id] = animation
end

---@param key number|string
function M.remove(key)
	active[key] = nil
end

---@param timer uv.uv_timer_t
---@param delay number
---@param callback fun()
function M.start(timer, delay, callback)
	timer:start(math.max(0, math.floor(delay)) --[[@as integer]], 0, callback)
end

---@param timer uv.uv_timer_t?
function M.close(timer)
	if timer then
		timer:stop()
		timer:close()
	end
end

---@return uv.uv_timer_t?
function M.timer()
	return uv.new_timer()
end

return M
