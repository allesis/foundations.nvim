local M = {} -- Replacements
local N = {} -- Post Replacements, done last
local O = {} -- Final Replacements, for cleanup and user positioning

-- Basic Replacements
-- Commonly used
M.date = {
	from = "{{__date__}}",
	to = function(match)
		local res = vim.api.nvim_exec2("!date", { output = true }).output
		-- !date returns a string with a bunch of garbage surrounding the actual date
		-- This strips the garbage
		return string.sub(res, 10, -2)
	end,
}

M.title = {
	from = "{{__title__}}",
	to = function(match)
		return vim.fs.basename(vim.api.nvim_buf_get_name(0))
	end,
	post_create = true,
}
M.time = {
	from = "{{__time__}}",
	to = function(match)
		return vim.uv.clock_gettime("realtime").sec
	end,
}
M.path = {
	from = "{{__path__}}",
	to = function(match)
		local path = vim.api.nvim_buf_get_name(0)
		return path
	end,
}
M.name = {
	from = "{{__name__}}",
	to = function(match)
		return vim.uv.os_get_passwd().username
	end,
}

-- Advanced replacements
-- These use lua magic and do useful things

-- Niece replacements
-- Really unlikely to be used,
-- but you never know

-- These two are here entirely to allow entering the template strings directly into a template without replacement
-- So {{__left__}}some_template_string{{__right__}}
-- will become {{__some_template_string__}} after replacements have been made
N.left = {
	from = "{{__left__}}",
	to = function(match)
		return "{{__"
	end,
}

N.right = {
	from = "{{__right__}}",
	to = function(match)
		return "__}}"
	end,
}
--
-- Wrappers around command line functions
-- These are just here to allow dedicated users to go to town on templates

-- Allows embedding of any date command, each command is run at a different moment in time
M.date_with_string = {
	from = "{{__date__[%%\\:a-zA-Z]+__}}",
	to = function(from)
		local match = from or ""
		match = string.gsub(match, "{{__date__", "")
		match = string.gsub(match, "__}}", "")
		match = '!date +"' .. match .. '"'
		local res = string.sub(vim.api.nvim_exec2(match, { output = true }).output, string.len(match) + 4, -2)
		return res
	end,
}

-- Cleanup Replacements
-- Less actual replacements and more meta tokens used to indicate where various things should be located
O.cursor = {
	from = "{{__cursor__}}",
	to = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local line_number = 1
		for _, line in pairs(lines) do
			local column_number = string.find(line, O.cursor.from)
			if column_number then
				local new_line = string.gsub(line, O.cursor.from, "")
				vim.api.nvim_buf_set_lines(bufnr, line_number - 1, line_number, true, { new_line })
				vim.api.nvim_win_set_cursor(0, { line_number, column_number - 1 })
				return
			end
			line_number = line_number + 1
		end
	end,
}
return { M, N, O }
