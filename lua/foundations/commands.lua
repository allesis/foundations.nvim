local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local util = require("foundations.util")
local M = {}
local edit_template = function(template_path)
	local oldbuf = vim.api.nvim_get_current_buf()
	--TODO: This will break on specific paths, e.g. leading ~ or /
	template_path = vim.fs.normalize(template_path)
	vim.cmd.e(template_path)
	local newbuf = vim.api.nvim_get_current_buf()
	vim.api.nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
		buffer = newbuf,
		desc = "Return to previous buffer after exiting a template edit buffer.",
		callback = function()
			if vim.api.nvim_buf_is_valid(oldbuf) then
				vim.api.nvim_set_current_buf(oldbuf)
			else
				require("foundations")._configs.intro()
			end
			vim.api.nvim_buf_delete(newbuf, { force = true })
		end,
	})
end
M.new_template = function(opts)
	opts = opts or {}
M.edit_template = function(opts)
	opts = opts or {}
end
M.from_template = function(opts)
	opts = opts or {}
end
end
return M
