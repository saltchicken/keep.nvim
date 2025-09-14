local M = {}

-- Default configuration
local config = {
	notes_dir = vim.fn.expand("~/.config/nvim/notes/"), -- directory for notes
	current_file = nil, -- currently open note
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
	picker_opts = {
		width = 40,
		height = math.floor(vim.o.lines * 0.8),
		row = math.floor(vim.o.lines * 0.1),
		col = math.floor((vim.o.columns - 40) / 2),
		border = "rounded",
		title = " Notes Picker ",
		title_pos = "center",
	},
}

-- Floating window and buffer
local float_win = nil
local float_buf = nil

-- Setup function
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	config.notes_dir = vim.fn.expand(config.notes_dir)

	-- ensure directory exists
	vim.fn.mkdir(config.notes_dir, "p")

	-- Map <leader>kn to open floating picker
	vim.keymap.set("n", "<leader>kn", function()
		local snacks = require("snacks")
		snacks.picker.files({
			cwd = config.notes_dir,
			preview = true,
			float = config.picker_opts,
			on_select = function(item)
				M.open_notes_with(item.path)
			end,
		})
	end, { desc = "Open Notes (floating picker)" })
end

-- Create or reuse buffer
local function create_notes_buffer()
	if float_buf and vim.api.nvim_buf_is_valid(float_buf) then
		return float_buf
	end

	float_buf = vim.api.nvim_create_buf(false, false)

	vim.api.nvim_buf_set_option(float_buf, "buftype", "acwrite")
	vim.api.nvim_buf_set_option(float_buf, "filetype", "markdown")
	vim.api.nvim_buf_set_name(float_buf, config.current_file)

	if vim.fn.filereadable(config.current_file) == 1 then
		local lines = vim.fn.readfile(config.current_file)
		vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
		vim.api.nvim_buf_set_option(float_buf, "modified", false)
	end

	local augroup = vim.api.nvim_create_augroup("KeepNvim", { clear = false })

	-- Save on :w
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

	-- Save on quit
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

-- Open floating notes window
function M.open_notes()
	if not config.current_file then
		print("No note selected. Use <leader>kn to open picker.")
		return
	end

	if float_win and vim.api.nvim_win_is_valid(float_win) then
		M.close_notes()
		return
	end

	local buf = create_notes_buffer()
	local opts = vim.tbl_deep_extend("force", config.float_opts, {
		col = math.floor((vim.o.columns - config.float_opts.width) / 2),
		row = math.floor((vim.o.lines - config.float_opts.height) / 2),
		title = " " .. vim.fn.fnamemodify(config.current_file, ":t") .. " ",
	})

	float_win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_win_set_option(float_win, "winhl", "Normal:Normal,FloatBorder:FloatBorder")

	-- buffer-local keymaps
	vim.keymap.set("n", "<Esc>", M.close_notes, { buffer = buf, silent = true })
	vim.keymap.set("n", "q", M.close_notes, { buffer = buf, silent = true })
end

-- Open a specific note file (called by picker)
function M.open_notes_with(file)
	config.current_file = file
	M.open_notes()
end

-- Close floating window
function M.close_notes()
	if float_win and vim.api.nvim_win_is_valid(float_win) then
		vim.api.nvim_win_close(float_win, false)
		float_win = nil
	end
end

-- Expose config
function M.get_config()
	return config
end

return M
