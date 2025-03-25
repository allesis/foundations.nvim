vim.api.nvim_create_user_command("Foundations", function(opts)
	opts = opts or "~/.template"
	print(opts.args)
end, {
	nargs = 1,
	complete = function(ArgLead, CmdLine, CursorPos)
		return { "NewTemplate", "FromTemplate", "EditTemplate" }
	end,
})
