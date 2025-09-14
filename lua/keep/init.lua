local M = {}

-- Default configuration
local config = {
	notes_dir = vim.fn.expand("~/.config/nvim/notes/"), -- Directory for multiple notes
	current_file = nil, -- The note currently being edited
	float_opts = {
		relative = "editor",
		width = 80,
		height = 24,
		border = "rounded",
		title_pos = "center",
	},
	sidebar_width = 40, -- Snacks sidebar width
}

-- Store floating window and buffer
local float_win = nil
local float_buf = nil

-- Setup function
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	config.notes_dir = vim.fn.expand(config.notes_dir)

	-- Ensure notes dir exists
	vim.fn.mkdir(config.notes_dir, "p")

	-- Keymap
	vim.keymap.set("n", "<leader>kn", M.pick_note, { desc = "Pick a note file", noremap = true, silent = true })

	-- Command
	vim.api.nvim_create_user_command("KeepNotes", function()
		vim.schedule(M.pick_note) -- schedule to ensure normal-mode-like behavior
	end, { desc = "Pick a note file (same as <leader>kn)" })
end

-- Picker using snacks.nvim as a vertical sidebar
function M.pick_note()
	local snacks = require("snacks")

	snacks.picker.files({
		cwd = config.notes_dir,
		preview = true,
		layout = "vertical",
		width = config.sidebar_width,
		on_select = function(item)
			config.current_file = item.path
			M.open_notes()
		end,
	})
end

-- Create or get the notes buffer
local function create_notes_buffer()
	if float_buf and vim.api.nvim_buf_is_valid(float_buf) then
		return float_buf
	end

	float_buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_option(float_buf, "buftype", "acwrite")
	vim.api.nvim_buf_set_option(float_buf, "filetype", "markdown")
	vim.api.nvim_buf_set_name(float_buf, config.current_file)

	-- Load content if the file exists
	if vim.fn.filereadable(config.current_file) == 1 then
		local lines = vim.fn.readfile(config.current_file)
		vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
		vim.api.nvim_buf_set_option(float_buf, "modified", false)
	end

	-- Autocommands for saving and closing
	local augroup = vim.api.nvim_create_augroup("KeepNvim", { clear = false })

	-- Write to disk when buffer is saved
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		group = augroup,
		buffer = float_buf,
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(float_buf, 0, -1, false)
			local dir = vim.fn.fnamemodify(config.current_file, ":h")
			vim.fn.mkdir(dir, "p")
			vim.fn.writefile(lines, config.current_file)
			vim.api.nvim_buf_set_option(float_buf, "modified", false)
			print("Notes saved to " .. config.current_file)
		end,
	})

	-- Close floating window on quit
	vim.api.nvim_create_autocmd("QuitPre", {
		group = augroup,
		buffer = float_buf,
		callback = function()
			if float_win and vim.api.nvim_win_is_valid(float_win) then
				if vim.api.nvim_buf_get_option(float_buf, "modified") then
					vim.cmd("write")
				end
				M.close_notes()
			end
		end,
	})

	return float_buf
end

-- Open the note in a floating window
function M.open_notes()
	if not config.current_file then
		print("No note selected. Run <leader>kn or :KeepNotes")
		return
	end

	-- Toggle close if already open
	if float_win and vim.api.nvim_win_is_valid(float_win) then
		M.close_notes()
		return
	end

	local buf = create_notes_buffer()
	local width, height = config.float_opts.width, config.float_opts.height
	local opts = vim.tbl_deep_extend("force", config.float_opts, {
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		width = width,
		height = height,
		title = " " .. vim.fn.fnamemodify(config.current_file, ":t") .. " ",
	})

	float_win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_win_set_option(float_win, "winhl", "Normal:Normal,FloatBorder:FloatBorder")

	-- Close mappings
	vim.keymap.set("n", "<Esc>", M.close_notes, { buffer = buf, noremap = true, silent = true })
	vim.keymap.set("n", "q", M.close_notes, { buffer = buf, noremap = true, silent = true })
end

-- Close the floating window
function M.close_notes()
	if float_win and vim.api.nvim_win_is_valid(float_win) then
		vim.api.nvim_win_close(float_win, false)
		float_win = nil
	end
end

return M
