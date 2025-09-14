local M = {}

-- Default configuration
M.config = {
	dir = vim.fn.expand("~/.config/nvim/keepnotes"),
}

function M.setup(opts)
	M.config = vim.tbl_extend("force", M.config, opts or {})
end

-- Open the first file in the configured directory
function M.open_first()
	local dir = vim.fn.expand(M.config.dir)
	local all_files = vim.fn.readdir(dir)
	local files = {}

	for _, name in ipairs(all_files) do
		local full_path = dir .. "/" .. name
		if vim.fn.isdirectory(full_path) == 0 then
			table.insert(files, name)
		end
	end

	if #files > 0 then
		table.sort(files)
		local first_file = dir .. "/" .. files[1]
		vim.cmd.edit(first_file)
	else
		vim.notify("No files found in " .. dir, vim.log.levels.WARN)
	end
end

-- Open the snacks explorer
function M.open_picker()
	require("snacks").explorer.open({
		cwd = M.config.dir,
	})
end

-- Command that opens both first file and explorer
vim.api.nvim_create_user_command("KeepNotes", function()
	M.open_first()
	M.open_picker()
end, {})

return M
