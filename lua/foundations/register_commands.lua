local commands = require("foundations.commands")
local command_names = {
	"FromTemplate",
	"NewTemplate",
	"EditTemplate",
}
local commands_functions = {
	["NewTemplate"] = commands.new_template,
	["FromTemplate"] = commands.from_template,
	["EditTemplate"] = commands.edit_template,
}

vim.api.nvim_create_user_command("Foundations", function(opts)
	opts = opts or "~/.template"
	local args = {}

	for token in string.gmatch(opts.args, "[^%s]+") do
		table.insert(args, token)
	end
	for _, arg in pairs(args) do
		commands_functions[arg]()
	end
end, {
	nargs = 1,
	complete = function(ArgLead, CmdLine, CursorPos)
		local args = {}
		for token in string.gmatch(CmdLine, "[^%s]+") do
			table.insert(args, token)
		end
		-- args.1 is "Foundations", and will always be, just remove it
		_ = table.remove(args, 1)
		vim.api.nvim_err_writeln("LEN " .. vim.tbl_count(args) .. "")
		vim.api.nvim_err_writeln("ARGLEAD " .. ArgLead)
		vim.api.nvim_err_writeln("ARGLEAD size " .. string.len(ArgLead))
		local args_count = vim.tbl_count(args)
		if args_count >= 3 then
			return {}
		elseif args_count == 0 then
			return command_names
		elseif string.match(args[1], command_names[1]) then
			return {}
		elseif args_count == 2 or (args_count == 1 and string.len(ArgLead) == 0) then
			return vim.tbl_filter(function(a)
				vim.api.nvim_err_writeln(
					vim.inspect(require("foundations.util").get_templates(require("foundations")._configs.path))
				)
				return string.match(a, ArgLead) ~= nil
			end, require("foundations.util").get_templates(require("foundations")._configs.path))
		else
			return vim.tbl_filter(function(a)
				return string.match(a, ArgLead) ~= nil
			end, command_names)
		end
	end,
})
