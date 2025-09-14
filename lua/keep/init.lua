local M = {}

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

-- Open the snacks explorer and reveal the current file
function M.open_explorer()
	local snacks = require("snacks")
	snacks.explorer.open({
		cwd = M.config.dir,
		path = vim.api.nvim_buf_get_name(0), -- reveal current buffer
	})

	-- Auto-update explorer selection when switching buffers
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("KeepNotesExplorer", { clear = true }),
		callback = function()
			local buf_path = vim.api.nvim_buf_get_name(0)
			if buf_path:find(M.config.dir, 1, true) == 1 then
				snacks.explorer.reveal(buf_path)
			end
		end,
	})
end

-- Command that opens first file + explorer
vim.api.nvim_create_user_command("KeepNotes", function()
	M.open_first()
	M.open_explorer()
end, {})

return M
