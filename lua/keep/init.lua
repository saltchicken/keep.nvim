-- keep.lua
local M = {}

-- Default configuration
M.config = {
	dir = vim.fn.expand("~/.config/nvim/keepnotes"),
	sidebar_width = 40,
	preview_width = 80,
}

--- Setup function (for user overrides)
-- @param opts table
function M.setup(opts)
	M.config = vim.tbl_extend("force", M.config, opts or {})

	vim.api.nvim_create_user_command("KeepNotes", function()
		M.open_notes_explorer()
	end, {})
end

--- Open Snacks Explorer with persistent preview
function M.open_notes_explorer()
	local snacks = require("snacks")

	snacks.explorer.open({
		cwd = M.config.notes_dir,
		layout = "left", -- sidebar style
		width = M.config.sidebar_width,
		preview = {
			enabled = true, -- always enable preview
			win = {
				relative = "editor",
				width = M.config.preview_width,
			},
		},
		on_load = function(picker)
			-- Enter to open the file
			picker:map("n", "<CR>", function()
				picker:select({ open = "edit" })
			end)

			-- Force preview refresh
			picker:map("n", "<Tab>", function()
				picker:preview()
			end)
		end,
	})
end

return M
