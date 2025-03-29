local M = {}

M.title = {
	from = "{{__title__}}",
	to = function()
		return vim.api.nvim_buf_get_name(0)
	end,
}
M.time = {
	from = "{{__time__}}",
	to = function()
		return vim.uv.clock_gettime()
	end,
}
M.path = {
	from = "{{__path__}}",
	to = function() end,
}
return M
