if vim.g.loaded_animate_nvim then
	return
end
vim.g.loaded_animate_nvim = true

require("animate").setup()
