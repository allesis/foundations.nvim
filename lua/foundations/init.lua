local M = {}

--[[
--	A list of all the available templates
--	Need to be of the form of template_spec
--]]
local replacements = require("foundations.replacements")
M._configs = {
	path = "~/.config/nvim/templates",
	replacements = replacements[1],
	post_replacements = replacements[2],
	cleanup_replacements = replacements[3],
	-- TODO: Add options to use startify and dashboard
	intro = function()
		vim.cmd.intro()
	end,
	markers = {},
	-- Valid strategies are: all, marker, git, lsp, none
	-- If `all` is used, order is LSP, git, markers, none
	root_strategy = "all",
}
M.config = function(config)
	if config ~= nil and config.path ~= nil then
		M._configs = vim.tbl_deep_extend("force", M._configs, config)
	end
end
M.setup = function(config)
	M.config(config)
	require("foundations.register_commands")
end

return M
