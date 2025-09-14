local M = {}

-- Default configuration
M.config = {
	dir = vim.fn.expand("~/.config/nvim/keepnotes"), -- change this to the directory you want
}

--- Setup function (for user overrides)
-- @param opts table
function M.setup(opts)
	M.config = vim.tbl_extend("force", M.config, opts or {})
end

--- Open a file picker for the configured directory
function M.open()
	require("snacks").explorer.open({
		cwd = M.config.dir,
		width = 30,
		view = "flat",
	})
end

vim.api.nvim_create_user_command("KeepNotes", function()
	M.open()
end, {})

return M
