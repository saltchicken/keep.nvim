local M = {}

-- Default configuration
local config = {
	notes_file = vim.fn.expand("~/.config/nvim/notes.md"), -- Default location
	float_opts = {
		relative = "editor",
		width = 80,
		height = 24,
		col = math.floor((vim.o.columns - 80) / 2),
		row = math.floor((vim.o.lines - 24) / 2),
		border = "rounded",
		title = " Notes ",
		title_pos = "center",
	},
}

-- Store the floating window and buffer
local float_win = nil
local float_buf = nil

-- Setup function to configure the plugin
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})

	-- Expand the notes_file path to handle ~ and other path expansions
	config.notes_file = vim.fn.expand(config.notes_file)

	-- Create keymapping
	vim.keymap.set("n", "<leader>kn", M.open_notes, {
		desc = "Open floating notes",
		silent = true,
	})
end

-- Function to create or get the notes buffer
local function create_notes_buffer()
	if float_buf and vim.api.nvim_buf_is_valid(float_buf) then
		return float_buf
	end

	float_buf = vim.api.nvim_create_buf(false, false)

	-- Set buffer options
	vim.api.nvim_buf_set_option(float_buf, "buftype", "acwrite")
	vim.api.nvim_buf_set_option(float_buf, "filetype", "markdown")
	vim.api.nvim_buf_set_name(float_buf, config.notes_file)

	-- Load existing content if file exists
	if vim.fn.filereadable(config.notes_file) == 1 then
		local lines = vim.fn.readfile(config.notes_file)
		vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
		vim.api.nvim_buf_set_option(float_buf, "modified", false)
	end

	-- Set up autocommands for this buffer
	local augroup = vim.api.nvim_create_augroup("KeepNvim", { clear = false })

	-- Handle saving
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		group = augroup,
		buffer = float_buf,
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(float_buf, 0, -1, false)

			-- Ensure directory exists
			local dir = vim.fn.fnamemodify(config.notes_file, ":h")
			vim.fn.mkdir(dir, "p")

			-- Write file
			vim.fn.writefile(lines, config.notes_file)
			vim.api.nvim_buf_set_option(float_buf, "modified", false)
			print("Notes saved to " .. config.notes_file)
		end,
	})

	-- Handle :wq command
	vim.api.nvim_create_autocmd("QuitPre", {
		group = augroup,
		buffer = float_buf,
		callback = function()
			if float_win and vim.api.nvim_win_is_valid(float_win) then
				-- Check if buffer is modified and save if needed
				if vim.api.nvim_buf_get_option(float_buf, "modified") then
					vim.cmd("write")
				end
				M.close_notes()
			end
		end,
	})

	return float_buf
end

-- Function to open the floating notes window
function M.open_notes()
	-- Close existing window if open
	if float_win and vim.api.nvim_win_is_valid(float_win) then
		M.close_notes()
		return
	end

	-- Create or get buffer
	local buf = create_notes_buffer()

	-- Calculate window position
	local width = config.float_opts.width
	local height = config.float_opts.height

	local opts = vim.tbl_deep_extend("force", config.float_opts, {
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
	})

	-- Create floating window
	float_win = vim.api.nvim_open_win(buf, true, opts)

	-- Set window options
	vim.api.nvim_win_set_option(float_win, "winhl", "Normal:Normal,FloatBorder:FloatBorder")

	-- Set buffer-local keymaps for easier closing
	vim.keymap.set("n", "<Esc>", M.close_notes, {
		buffer = buf,
		silent = true,
		desc = "Close notes",
	})
	vim.keymap.set("n", "q", M.close_notes, {
		buffer = buf,
		silent = true,
		desc = "Close notes",
	})
end

-- Function to close the floating notes window
function M.close_notes()
	if float_win and vim.api.nvim_win_is_valid(float_win) then
		vim.api.nvim_win_close(float_win, false)
		float_win = nil
	end
end

-- Function to get current config (useful for debugging)
function M.get_config()
	return config
end

return M
