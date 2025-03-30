local M = {}
local config_path = require("foundations")._configs.path

local getline = function()
	return vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
end

M.float = function(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.25)
	local height = opts.height or 1

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
	return buf, win
end

M.get_templates = function(path)
	path = path or config_path
	local templates = {}
	local ignore_dirs = require("foundations")._configs.ignore_dirs or {}
	local entries = vim.fs.dir(path, { depth = 0 })
	for entry in entries do
		if vim.tbl_contains(ignore_dirs, entry) then
			goto continue
		end
		local filetype = vim.uv.fs_stat(vim.fs.normalize(path .. "/" .. entry)).type
		if filetype == "directory" then
			for _, template in pairs(M.get_templates(path .. "/" .. entry)) do
				table.insert(templates, template)
			end
		else
			table.insert(templates, path .. "/" .. entry)
		end
		::continue::
	end
	return templates
end

M.get_dirs = function(path)
	path = path or config_path
	local dirs = { path .. "/" }
	local ignore_dirs = require("foundations")._configs.ignore_dirs or {}
	local entries = vim.fs.dir(path, { depth = 0 })
	for entry in entries do
		if vim.tbl_contains(ignore_dirs, entry) then
			goto continue
		end
		local entry_path = path .. "/" .. entry
		local filetype = vim.uv.fs_stat(vim.fs.normalize(entry_path)).type
		if filetype == "directory" then
			for _, subdir in pairs(M.get_dirs(entry_path)) do
				table.insert(dirs, subdir)
			end
		end
		::continue::
	end
	return dirs
end

-- Function takes a callafter function and opts
-- Opts are used in the function but must contain all args to be passed to callafter
-- Callafter is a function with the signature function(callafter, opts)
-- To escape this hope pass a callafter function which calls a function which does not align to this signature
M.get_name = function(callafter, opts)
	opts = opts or {}
	local buf, win = M.float(opts)
	vim.cmd("startinsert")
	vim.keymap.set("i", "<CR>", function()
		local path = getline()
		vim.cmd("stopinsert")
		vim.api.nvim_win_close(win, false)
		-- FIX: This can wipeout a pre-existing file
		if (not opts.editing) or assert(vim.uv.fs_stat(path)) then
			callafter(path, opts)
		end
	end, { buffer = true })
	vim.keymap.set("i", ":", "<ESC>:", { buffer = true })
	vim.keymap.set({ "i", "n" }, "<ESC>", function()
		vim.cmd("stopinsert")
		vim.api.nvim_win_close(win, true)
	end, { buffer = true })
end

M.edit_template = function(template_path)
	local oldbuf = vim.api.nvim_get_current_buf()
	--TODO: This will break on specific paths, e.g. leading ~ or /
	template_path = vim.fs.normalize(template_path)
	vim.cmd.e(template_path)
	local newbuf = vim.api.nvim_get_current_buf()
	vim.api.nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
		buffer = newbuf,
		desc = "Return to previous buffer after exiting a template edit buffer.",
		callback = function()
			if vim.api.nvim_buf_is_valid(oldbuf) then
				vim.api.nvim_set_current_buf(oldbuf)
			else
				require("foundations")._configs.intro()
			end
			vim.api.nvim_buf_delete(newbuf, { force = true })
		end,
	})
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
	local filetype = vim.uv.fs_stat(file_path)
	if filetype then
		assert(
			filetype.type == "file",
			"\nFoundations.nvim tried to write to something other than a file!\nDid you forget to enter a file name?"
		)
	end
	local fd = assert(vim.uv.fs_open(file_path, "w", 438))
	local bytes = assert(vim.uv.fs_write(fd, contents, 0))
	assert(vim.uv.fs_close(fd))
	return bytes
end

-- Creates a new file with contents equal to the file at template_path and saves it at file_path
M.file_from_template = function(template_path, file_path)
	template_path = vim.fs.normalize(template_path)
	file_path = vim.fs.normalize(file_path)
	local contents = M.read_file(template_path)
	vim.cmd.e(file_path)
	contents = M.replace_standins(contents)
	M.write_file(file_path, contents)
	-- PERF: This edit is very slow for no reason
	-- 	 I've tried profiling a bit but no obvious reasons for bad perf
	-- 	 It's gotten better own its own for some reason but is still slow
	-- FIX:  Make this faster. Waiting a half second for a file to open is annoying
	vim.cmd.e(file_path)
	vim.cmd.w()
	M.do_cleanup()
end

M.apply_replacements = function(file_path) end

-- Replaces all registered standins in contents with the result of calling their associated function
-- Order of operations is determined by priority
-- {{__cursor__}} is always processed last
M.replace_standins = function(contents)
	local replacements = require("foundations")._configs.replacements or {}
	for _, replace_spec in pairs(replacements) do
		contents = string.gsub(contents, replace_spec.from, replace_spec.to)
	end
	local post_replacements = require("foundations")._configs.post_replacements or {}
	for _, replace_spec in pairs(post_replacements) do
		contents = string.gsub(contents, replace_spec.from, replace_spec.to)
	end
	return contents
end

M.get_project_root = function(path)
	local strategy = require("foundations")._configs.root_strategy
	local markers = require("foundations")._configs.markers

	local lsp = vim.lsp.get_clients({ buffer = 0 })[1] or {}
	if vim.tbl_contains({ "all", "lsp" }, strategy) and lsp.root_dir then
		return lsp.root_dir
	end
	if vim.tbl_contains({ "all", "git" }, strategy) then
		local resp = vim.api.nvim_exec2("!git rev-parse --show-toplevel", { output = true }).output
		if resp ~= "fatal: not a git repository (or any of the parent directories): .git" and resp then
			return resp
		end
	end
	if vim.tbl_contains({ "all", "markers" }, strategy) and markers then
		local root = vim.fs.root(path, markers)
		if root then
			return root
		end
	end
	return vim.fs.dirname(path)
end

M.do_cleanup = function()
	local cleanup_replacements = require("foundations")._configs.cleanup_replacements or {}
	for _, replace_spec in pairs(cleanup_replacements) do
		replace_spec.to()
	end
end

return M
