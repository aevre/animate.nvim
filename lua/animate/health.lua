local M = {}

local health = vim.health
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local error = health.error or health.report_error

function M.check()
	start("animate.nvim")
	if vim.fn.has("nvim-0.10") == 1 then
		ok("Neovim 0.10+ is available")
	else
		error("Neovim 0.10+ is required")
	end

	local uv = vim.uv or vim.loop
	if uv and type(uv.new_timer) == "function" then
		ok("libuv timer support is available")
	else
		error("libuv timer support is unavailable")
	end
end

return M
