local new_template = function()
	print("new template")
end

local from_template = function()
	print("from template")
end

local edit_template = function()
	print("edit template")
end
local command_names = {
	"NewTemplate",
	"FromTemplate",
	"EditTemplate",
}
local commands_functions = {
	["NewTemplate"] = new_template,
	["FromTemplate"] = from_template,
	["EditTemplate"] = edit_template,
}

vim.api.nvim_create_user_command("Foundations", function(opts)
	opts = opts or "~/.template"
	print(vim.inspect(opts))
	print(opts.args)
	-- From here
	local args = {}

	for token in string.gmatch(opts.args, "[^%s]+") do
		table.insert(args, token)
	end
	-- To here comes from this: https://stackoverflow.com/questions/1426954/split-string-in-lua
	-- Stackoverflow question
	for _, arg in pairs(args) do
		commands_functions[arg]()
	end
end, {
	nargs = 1,
	complete = function(ArgLead, CmdLine, CursorPos)
		return command_names
	end,
})
