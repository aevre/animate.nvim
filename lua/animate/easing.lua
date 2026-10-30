local PI = math.pi
local sin, cos, sqrt, pow = math.sin, math.cos, math.sqrt, math.pow

local function linear(t, b, c, d)
	return c * t / d + b
end

local function in_quad(t, b, c, d)
	t = t / d
	return c * t * t + b
end

local function out_quad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

local function in_out_quad(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t + b
	end
	t = t - 1
	return -c / 2 * (t * (t - 2) - 1) + b
end

local function in_cubic(t, b, c, d)
	t = t / d
	return c * t * t * t + b
end

local function out_cubic(t, b, c, d)
	t = t / d - 1
	return c * (t * t * t + 1) + b
end

local function in_out_cubic(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t + b
	end
	t = t - 2
	return c / 2 * (t * t * t + 2) + b
end

local function in_poly(power)
	return function(t, b, c, d)
		return c * pow(t / d, power) + b
	end
end

local function out_poly(power)
	return function(t, b, c, d)
		return c * (pow(t / d - 1, power) * (power % 2 == 0 and -1 or 1) + 1) + b
	end
end

local function in_out_poly(power)
	local in_fn, out_fn = in_poly(power), out_poly(power)
	return function(t, b, c, d)
		if t < d / 2 then
			return (in_fn(t * 2, 0, c, d) - 0) / 2 + b
		end
		return out_fn(t * 2 - d, b + c / 2, c / 2, d)
	end
end

local function in_sine(t, b, c, d)
	return -c * cos(t / d * (PI / 2)) + c + b
end

local function out_sine(t, b, c, d)
	return c * sin(t / d * (PI / 2)) + b
end

local function in_out_sine(t, b, c, d)
	return -c / 2 * (cos(PI * t / d) - 1) + b
end

local function in_expo(t, b, c, d)
	return t == 0 and b or c * pow(2, 10 * (t / d - 1)) + b
end

local function out_expo(t, b, c, d)
	return t == d and b + c or c * (-pow(2, -10 * t / d) + 1) + b
end

local function in_out_expo(t, b, c, d)
	if t == 0 or t == d then
		return t == 0 and b or b + c
	end
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(2, 10 * (t - 1)) + b
	end
	return c / 2 * (-pow(2, -10 * (t - 1)) + 2) + b
end

local function in_circ(t, b, c, d)
	return -c * (sqrt(1 - (t / d) ^ 2) - 1) + b
end

local function out_circ(t, b, c, d)
	t = t / d - 1
	return c * sqrt(1 - t * t) + b
end

local function in_out_circ(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return -c / 2 * (sqrt(1 - t * t) - 1) + b
	end
	t = t - 2
	return c / 2 * (sqrt(1 - t * t) + 1) + b
end

local function in_back(t, b, c, d, s)
	s = s or 1.70158
	t = t / d
	return c * t * t * ((s + 1) * t - s) + b
end

local function out_back(t, b, c, d, s)
	s = s or 1.70158
	t = t / d - 1
	return c * (t * t * ((s + 1) * t + s) + 1) + b
end

local function in_out_back(t, b, c, d, s)
	s = (s or 1.70158) * 1.525
	t = t / d * 2
	if t < 1 then
		return c / 2 * (t * t * ((s + 1) * t - s)) + b
	end
	t = t - 2
	return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end

local function in_elastic(t, b, c, d, a, p)
	if c == 0 then
		return b
	end
	if t == 0 or t == d then
		return t == 0 and b or b + c
	end
	p = p or d * 0.3
	a = a or c
	if math.abs(c) > math.abs(a) then
		a = c
	end
	local s = p / (2 * PI) * math.asin(c / a)
	t = t / d - 1
	return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * PI) / p)) + b
end

local function out_elastic(t, b, c, d, a, p)
	if c == 0 then
		return b
	end
	if t == 0 or t == d then
		return t == 0 and b or b + c
	end
	p = p or d * 0.3
	a = a or c
	if math.abs(c) > math.abs(a) then
		a = c
	end
	local s = p / (2 * PI) * math.asin(c / a)
	t = t / d
	return a * pow(2, -10 * t) * sin((t * d - s) * (2 * PI) / p) + c + b
end

local function in_out_elastic(t, b, c, d, a, p)
	if c == 0 then
		return b
	end
	if t == 0 or t == d then
		return t == 0 and b or b + c
	end
	p = p or d * 0.45
	a = a or c
	local s = p / (2 * PI) * math.asin(c / a)
	t = t / d * 2
	if t < 1 then
		t = t - 1
		return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * PI) / p)) + b
	end
	t = t - 1
	return a * pow(2, -10 * t) * sin((t * d - s) * (2 * PI) / p) * 0.5 + c + b
end

local function out_bounce(t, b, c, d)
	t = t / d
	if t < 1 / 2.75 then
		return c * (7.5625 * t * t) + b
	elseif t < 2 / 2.75 then
		t = t - 1.5 / 2.75
		return c * (7.5625 * t * t + 0.75) + b
	elseif t < 2.5 / 2.75 then
		t = t - 2.25 / 2.75
		return c * (7.5625 * t * t + 0.9375) + b
	end
	t = t - 2.625 / 2.75
	return c * (7.5625 * t * t + 0.984375) + b
end

local function in_bounce(t, b, c, d)
	return c - out_bounce(d - t, 0, c, d) + b
end

local function in_out_bounce(t, b, c, d)
	if t < d / 2 then
		return in_bounce(t * 2, 0, c, d) * 0.5 + b
	end
	return out_bounce(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
end

---@enum (key) animate.easing
local M = {
	linear = linear,
	inQuad = in_quad,
	outQuad = out_quad,
	inOutQuad = in_out_quad,
	inCubic = in_cubic,
	outCubic = out_cubic,
	inOutCubic = in_out_cubic,
	inQuart = in_poly(4),
	outQuart = out_poly(4),
	inOutQuart = in_out_poly(4),
	inQuint = in_poly(5),
	outQuint = out_poly(5),
	inOutQuint = in_out_poly(5),
	inSine = in_sine,
	outSine = out_sine,
	inOutSine = in_out_sine,
	inExpo = in_expo,
	outExpo = out_expo,
	inOutExpo = in_out_expo,
	inCirc = in_circ,
	outCirc = out_circ,
	inOutCirc = in_out_circ,
	inBack = in_back,
	outBack = out_back,
	inOutBack = in_out_back,
	inElastic = in_elastic,
	outElastic = out_elastic,
	inOutElastic = in_out_elastic,
	inBounce = in_bounce,
	outBounce = out_bounce,
	inOutBounce = in_out_bounce,
}

return M
