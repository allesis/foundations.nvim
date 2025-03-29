local commands = require("foundations.commands")
local command_names = {
	"from_template",
	"new_template",
	"edit_template",
}
local commands_functions = {
	["new_template"] = commands.new_template,
	["from_template"] = commands.from_template,
	["edit_template"] = commands.edit_template,
}

vim.api.nvim_create_user_command("Foundations", function(opts)
	opts = opts or require("foundations")._configs.path
	local args = {}

	for token in string.gmatch(opts.args, "[^%s]+") do
		table.insert(args, token)
	end
	commands_functions[args[1]](args[2], opts)
end, {
	nargs = 1,
	complete = function(ArgLead, CmdLine, CursorPos)
		local _, args_count = string.gsub(CmdLine, " ", " ")
		if args_count > 1 then
			return {}
		else
			return vim.tbl_filter(function(a)
				return string.match(a, ArgLead) ~= nil
			end, command_names)
		end
	end,
})
