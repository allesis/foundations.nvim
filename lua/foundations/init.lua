local M = {}

--[[
--	A list of all the available templates
--	Need to be of the form of template_spec
--]]
M._templates = {}
M._configs = {
	path = "~/.config/nvim/templates",
	replacements = {
		title = {
			from = "{{__title__}}",
			to = function()
				return vim.api.nvim_buf_get_name(0)
			end,
		},
		time = {
			from = "{{__time__}}",
			to = function()
				return vim.uv.clock_gettime()
			end,
		},
	},
}
M.config = function(config)
	if config ~= nil and config.path ~= nil then
		M._configs = vim.tbl_deep_extend("force", M._configs, config)
	end
end
M.setup = function(config)
	M.config(config)
	require("foundations.register_commands")
	M._templates = require("foundations.util").get_templates(M._configs.path)
end

return M
