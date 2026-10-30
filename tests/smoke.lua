local animate = require("animate")
local easing = require("animate.easing")

local function approx(actual, expected)
	assert(math.abs(actual - expected) < 0.0001, ("expected %s, got %s"):format(expected, actual))
end

local function test_easings()
	for name, fn in pairs(easing) do
		assert(type(fn) == "function", name)
		approx(fn(0, 10, 20, 100), 10)
		approx(fn(100, 10, 20, 100), 30)
	end
	assert(easing.outBack(50, 0, 1, 100) > 0.5)
	assert(easing.inBounce(50, 0, 1, 100) < 0.5)
	assert(easing.outBounce(50, 0, 1, 100) > 0.5)
	for _, name in ipairs({ "inElastic", "outElastic", "inOutElastic" }) do
		local value = easing[name](50, 10, 20, 100)
		assert(value == value and math.abs(value) < 1000, name)
	end
end

local function test_api()
	assert(animate.setup({ duration = { total = 20 }, easing = "outQuad" }) == animate)
	assert(animate.easing.outQuad)
	assert(animate.enabled())
	vim.g.core_animate = false
	assert(not animate.enabled())
	vim.g.core_animate = nil

	local values = {}
	local animation = animate(0, 3, function(value, ctx)
		values[#values + 1] = { value, ctx.prev, ctx.done }
	end, { id = "smoke", int = true })
	assert(animation.id == "smoke")
	assert(#values == 0)
	for _ = 1, 20 do
		animation:step(function(value, ctx)
			values[#values + 1] = { value, ctx.prev, ctx.done }
		end)
	end
	assert(values[#values][1] == 3 and values[#values][3])
	assert(values[#values - 1][2] == values[#values - 1][1])

	local stopped = animate(0, 100, function() end, { id = "replace" })
	local replacement = animate(0, 1, function() end, { id = "replace" })
	assert(stopped.steps == nil and replacement.steps ~= nil)
	animate.del("replace")
	assert(replacement.steps == nil)

	local same = 0
	animate(5, 5, function(value, ctx)
		same = same + value
		assert(ctx.done and ctx.prev == value)
	end)
	assert(same == 5)
end

local ok, err = xpcall(function()
	test_easings()
	test_api()
end, debug.traceback)
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd("cquit 1")
end
print("animate.nvim smoke tests passed")
vim.cmd("qa!")
