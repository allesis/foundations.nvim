local M = {}

--[[
--	A list of all the available templates
--	Need to be of the form of template_spec
--]]
M._templates = {}
M._configs = {
	path = "~/.config/nvim/templates",
	replacements = require("foundations.replacements"),
	-- TODO: Add options to use startify and dashboard
	intro = function()
		vim.cmd.intro()
	end,
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
