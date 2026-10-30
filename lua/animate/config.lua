---@class animate.Configuration
local M = {}

---@type animate.Config
local defaults = {
	duration = 20,
	easing = "linear",
	fps = 120,
}

---@type animate.Config
local config = {}

---@param opts? animate.Config
---@return animate.Config
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	return vim.tbl_deep_extend("force", vim.deepcopy(defaults), vim.deepcopy(config))
end

---@return animate.Config
function M.get()
	return vim.tbl_deep_extend("force", vim.deepcopy(defaults), vim.deepcopy(config))
end

return M
