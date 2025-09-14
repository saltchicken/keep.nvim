local M = {}

M.config = {
	dir = vim.fn.expand("~/.config/nvim/keepnotes"),
}

function M.setup(opts)
	M.config = vim.tbl_extend("force", M.config, opts or {})
end

local function first_file_in_dir(dir)
	dir = vim.fn.expand(dir)
	local all = vim.fn.readdir(dir)
	local files = {}
	for _, name in ipairs(all) do
		local full = dir .. "/" .. name
		if vim.fn.isdirectory(full) == 0 and name:sub(1, 1) ~= "." then
			table.insert(files, name)
		end
	end
	table.sort(files)
	return files[1] and (dir .. "/" .. files[1]) or nil
end

function M.open_first()
	local f = first_file_in_dir(M.config.dir)
	if f then
		vim.cmd.edit(f)
	else
		vim.notify("No files found in " .. M.config.dir, vim.log.levels.WARN)
	end
end

function M.open_explorer()
	local snacks = require("snacks")

	-- open explorer with preview rendered into the main window
	local explorer = snacks.explorer.open({
		cwd = M.config.dir,
		path = vim.api.nvim_buf_get_name(0), -- highlight current buffer
		layout = { preset = "sidebar", preview = "main" }, -- preview appears in main area
		focus = "list",
		jump = { close = false }, -- don't auto-close on jump
		auto_close = false,
		follow_file = true, -- have explorer highlight current file
	})

	-- keep explorer selection in sync when you switch buffers
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("KeepNotesExplorer", { clear = true }),
		callback = function()
			local buf_path = vim.api.nvim_buf_get_name(0)
			if buf_path:find(M.config.dir, 1, true) == 1 and explorer and explorer.reveal then
				pcall(function()
					explorer:reveal(buf_path)
				end)
			end
		end,
	})
end

vim.api.nvim_create_user_command("KeepNotes", function()
	M.open_first()
	M.open_explorer()
end, {})

return M
