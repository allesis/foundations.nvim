local M = {}

-- Basic Replacements
-- Commonly used
M.date = {
	from = "{{__date__}}",
	to = function()
		return vim.api.nvim_exec2("!date", { output = true }).output
	end,
}

M.title = {
	from = "{{__title__}}",
	to = function()
		return vim.fs.basename(vim.api.nvim_buf_get_name(0))
	end,
}
M.fulldate = {
	from = "{{__fulldate__}}",
	to = function()
		return vim.cmd('!date +"%A the %d  of %B, %Y"')
	end,
}
M.path = {
	from = "{{__path__}}",
	to = function()
		return vim.api.nvim_buf_get_name(0)
	end,
}
M.name = {
	from = "{{__name__}}",
	to = function()
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
M.left = {
	from = "{{__left__}}",
	to = "{{__",
}

M.right = {
	from = "{{__right__}}",
	to = "__}}",
}

-- Wrappers around command line functions
-- These are just here to allow dedicated users to go to town on templates

M.date_with_string = {
	from = "({{__date__(.*)__}})",
	to = function(from)
		from = from or ""
		return vim.cmd('!date +""')
	end,
}
return M
