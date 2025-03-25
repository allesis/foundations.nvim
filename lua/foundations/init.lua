local M = {}

--[[
--	A list of all the available templates
--	Need to be of the form of template_spec
--]]
M._template = {}
M._configs = {
	path = "~/.config/nvim/templates",
}
M.setup = function(config)
	if config ~= nil and config.path ~= nil then
		M._configs.path = config.path
	end

	require("foundations.register_commands")
end

M.new_template = function(template_spec) end

M.file_from_template = function(template, name) end
return M
