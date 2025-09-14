local M = {}

-- Default configuration
M.config = {
	dir = vim.fn.expand("~/.config/nvim/keepnotes"),
}

function M.setup(opts)
	M.config = vim.tbl_extend("force", M.config, opts or {})
end

function M.open_first()
	local dir = vim.fn.expand(M.config.dir) -- make sure ~ is expanded
	vim.notify("Looking in directory: " .. dir)

	local all_files = vim.fn.readdir(dir)
	vim.notify("Found files: " .. table.concat(all_files, ", "))

	local files = {}
	for _, name in ipairs(all_files) do
		local full_path = dir .. "/" .. name
		if vim.fn.isdirectory(full_path) == 0 then -- is a file
			table.insert(files, name)
		end
	end

	if #files > 0 then
		table.sort(files)
		local first_file = dir .. "/" .. files[1]
		vim.notify("Opening file: " .. first_file)
		vim.cmd.edit(first_file)
	else
		vim.notify("No files found in " .. dir, vim.log.levels.WARN)
	end
end

vim.api.nvim_create_user_command("KeepNotes", function()
	M.open_first()
end, {})

return M
