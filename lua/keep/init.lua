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

	-- open sidebar explorer
	local explorer = snacks.explorer.open({
		cwd = M.config.dir,
		path = vim.api.nvim_buf_get_name(0),
		layout = { preset = "sidebar", preview = "main" },
		focus = "list",
		jump = { close = false }, -- don't close on confirm
		auto_close = false,
		follow_file = true,
	})

	-- Keep selection synced when switching buffers
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("KeepNotesExplorerSync", { clear = true }),
		callback = function()
			local buf_path = vim.api.nvim_buf_get_name(0)
			if buf_path:find(M.config.dir, 1, true) == 1 and explorer and explorer.reveal then
				pcall(function()
					explorer:reveal(buf_path)
				end)
			end
		end,
	})

	-- Force preview mode back on whenever you re-enter the explorer
	vim.api.nvim_create_autocmd("WinEnter", {
		group = vim.api.nvim_create_augroup("KeepNotesExplorerPreview", { clear = true }),
		callback = function()
			if vim.bo.filetype == "snacks_explorer" and explorer and explorer.set_mode then
				pcall(function()
					explorer:set_mode("preview")
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
