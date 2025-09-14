-- Plugin entry point - automatically loaded by Neovim
if vim.g.loaded_keep_nvim == 1 then
	return
end
vim.g.loaded_keep_nvim = 1

-- The plugin will be set up via require('keep').setup() in user's config
