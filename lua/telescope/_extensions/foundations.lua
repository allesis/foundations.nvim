local telescope = require("telescope")
local commands = require("foundations.commands")

return telescope.register_extension({
	setup = function() end,
	exports = {
		new_template = commands.new_template,
		edit_template = commands.edit_template,
		from_template = commands.from_template,
	},
})
