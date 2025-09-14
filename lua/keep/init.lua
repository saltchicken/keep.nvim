-- lua/mydirpicker/init.lua
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
		layout = "left",
		width = 30,
		on_open = function(item)
			print(item.path)
			-- tell keep.nvim to open the note in floating window
			-- keep.open_notes_with(item.path)
		end,
	})
end

-- Create a user command
vim.api.nvim_create_user_command("KeepNotes", function()
	M.open()
end, {})

return M
