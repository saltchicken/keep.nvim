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
	local all_files = vim.fn.readdir(M.config.dir) -- get everything

	-- filter out directories and hidden files
	local files = {}
	for _, name in ipairs(all_files) do
		local full_path = M.config.dir .. "/" .. name
		if vim.fn.isdirectory(full_path) == 0 and name:sub(1, 1) ~= "." then
			table.insert(files, name)
		end
	end

	if #files > 0 then
		table.sort(files) -- ensure consistent first
		local first_file = M.config.dir .. "/" .. files[1]
		vim.cmd.edit(first_file)
	else
		vim.notify("No files found in " .. M.config.dir, vim.log.levels.WARN)
	end
end

function M.open_picker()
	require("snacks").explorer.open({ cwd = M.config.dir })
end

vim.api.nvim_create_user_command("KeepNotes", function()
	M.open_first()
end, {})

return M
