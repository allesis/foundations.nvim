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

local ulimit_to = function(from)
	local match = from or ""
	match = string.gsub(match, "{{__ulimit__", "")
	match = string.gsub(match, "__}}", "")
	match = "!ulimit -" .. match
	return string.sub(vim.api.nvim_exec2(match, { output = true }).output, string.len(match) + 5, -2)
end

-- We need two ulimit commands since luas pattern matching is a touch limited
-- 	and N takes an arg of a number
M.ulimit_N = {
	from = "{{__ulimit__N[0-9]+__}}",
	to = ulimit_to,
}
M.ulimit = {
	from = "{{__ulimit__[tfdscmunlvxiqer]__}}",
	to = ulimit_to,
}

-- Cleanup Replacements
-- Less actual replacements and more meta tokens used to indicate where various things should be located
local perform_replacement = function(from, replace_function)
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local line_number = 1
	for _, line in pairs(lines) do
		local column_number = string.find(line, from)
		if column_number then
			local new_line = string.gsub(line, from, "")
			replace_function(new_line)
		end
		line_number = line_number + 1
	end
end
local cursor = function(new_line)
	vim.api.nvim_buf_set_lines(bufnr, line_number - 1, line_number, true, { new_line })
	vim.api.nvim_win_set_cursor(0, { line_number, column_number - 1 })
end
O.cursor = {
	from = "{{__cursor__}}",
	to = function()
		perform_replacement(O.cursor.from, cursor)
	end,
}

local run_neorg_command = function(command)
	local file_extension = vim.fs.basename(vim.api.nvim_buf_get_name(0))
	file_extension = string.match(file_extension, "%..")
	-- Make sure this can only be run on neorg command
	if file_extension then
		vim.cmd("Neorg " .. command)
	end
end

O.neorg_inject_metadata = {
	from = "{{__neorg__inject__metadata__}}",
	to = function()
		perform_replacement(O.neorg_inject_metadata.from, function()
			run_neorg_command("inject-metadata")
		end)
	end,
}
O.neorg_tangle = {
	from = "{{__neorg__tangle__}}",
	to = function()
		perform_replacement(O.neorg_inject_metadata.from, function()
			run_neorg_command("tangle current-file")
		end)
	end,
}

return { M, N, O }
