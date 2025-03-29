local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local util = require("foundations.util")
local M = {}
M.new_template = function(opts)
	opts = opts or {}
	local path = opts.path or nil
	local finder = finders.new_table({
		results = util.get_dirs(path),
		entry_maker = function(entry)
			return {
				value = entry,
				display = entry,
				ordinal = vim.fs.normalize(entry),
			}
		end,
	})
	pickers
		.new(opts, {
			prompt_title = "New Template Path",
			finder = finder,
			sorter = conf.file_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local template_path = action_state.get_selected_entry().value
					util.get_name(
						opts.callback
							or function(template_name, o)
								-- CHECK: Confirm this acts like edit when the file already exists
								util.edit_template(o.template_path .. "/" .. template_name)
							end,
						vim.tbl_deep_extend("keep", opts, { template_path = template_path, title = "Template Name" })
					)
				end)
				return true
			end,
		})
		:find()
end

M.edit_template = function(opts)
	opts = opts or {}
	local finder = finders.new_table({
		results = util.get_templates(),
		entry_maker = function(entry)
			return {
				value = entry,
				display = entry,
				ordinal = vim.fs.normalize(entry),
			}
		end,
	})

	pickers
		.new(opts, {
			prompt_title = "Edit Template",
			finder = finder,
			sorter = conf.file_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(opts.callback or function()
					actions.close(prompt_bufnr)
					local template_path = action_state.get_selected_entry().value
					util.edit_template(template_path)
				end)
				return true
			end,
		})
		:find()
end

M.from_template = function(opts)
	opts = opts or {}
	local finder = finders.new_table({
		results = util.get_templates(),
		entry_maker = function(entry)
			return {
				value = entry,
				display = entry,
				ordinal = vim.fs.normalize(entry),
			}
		end,
	})
	pickers
		.new(opts, {
			prompt_title = "New File From Template",
			finder = finder,
			sorter = conf.file_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					-- We are reusing the code in new_template to get us a valid file path
					-- 	without immedietly switching to it and closing it on save
					-- We do this by overloading the callback function it calls
					-- 	and spoofing some options
					-- The variable names are a bit confusing since the called function
					-- 	is not doing what the variable names would imply
					-- Here opts.from_template_path is the actual full template path
					-- In the callback, template_path is the file_path
					-- 	and file_namthe e is the file name
					-- HACK: This is a bad way to do things, either rename things
					-- 		to make it less confusing, or make the code less confusing
					local template_path = action_state.get_selected_entry().value
					opts.from_template_path = template_path
					opts.title = "New File Name"
					opts.prompt_title = "New File Path"
					opts.path = util.get_project_root(vim.api.nvim_buf_get_name(0))
					opts.callback = function(file_name, o)
						util.file_from_template(o.from_template_path, o.template_path .. "/" .. file_name)
					end
					M.new_template(opts)
				end)
				return true
			end,
		})
		:find()
end

return M
