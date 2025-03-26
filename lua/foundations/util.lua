local getline = function()
	return vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
end
local M = {}

M._state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

M.float = function(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.15)
	local height = opts.height or math.floor(vim.o.lines * 0.15)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local buf = vim.api.nvim_create_buf(false, true)

	local win_config = {
		relative = opts.relative or "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = opts.style or "minimal",
		border = opts.border or "rounded",
		title = opts.title or "",
		title_pos = opts.title_pos or "center",
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)
	M._state.floating = {
		buf = buf,
		win = win,
	}
	return buf, win
end

M.get_templates = function(path)
	local templates = {}
	local entries = vim.fs.dir(path, { depth = 5 })
	for entry in entries do
		if vim.filetype.match({ filename = entry }) == nil then
			templates = vim.tbl_extend("keep", templates, M.get_templates(path .. "/" .. entry))
		else
			table.insert(templates, path .. "/" .. entry)
		end
	end
	return templates
end

-- Reads the value of contents from the file at file_path
M.read_file = function(file_path)
	local fd = assert(vim.uv.fs_open(file_path, "r", 438))
	local stat = assert(vim.uv.fs_fstat(fd))
	local data = assert(vim.uv.fs_read(fd, stat.size, 0))
	assert(vim.uv.fs_close(fd))
	return data
end

-- Writes the value of contents to a new file at file_path
-- returns the number of bytes written
M.write_file = function(file_path, contents)
	local fd = assert(vim.uv.fs_open(file_path, "w", 438))
	local bytes = assert(vim.uv.fs_write(fd, contents, 0))
	assert(vim.uv.fs_close(fd))
	return bytes
end

-- Creates a new file with contents equal to the file at template_path and saves it at file_path
M.file_from_template = function(template_path, file_path)
	local contents = M.read_file(template_path)
	M.write_file(file_path, contents)
end
return M
