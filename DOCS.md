# Customization
Most of the default options should work for most users.
However there are many options some users may want to modify to fully customize how the plugin acts.
Here is a (non)exhaustive list of ~~all~~some available customization options.

## Path
By default templates are stored in the path `~/.config/nvim/templates`.
If you wish to change this you can with the path option.
Add the following snippet to the `opts` table from the installation step.
```lua
...
opts = {
...
  path = "/path/to/templates/dir",
...
},
...
```
Be aware that this will not move your templates so any pre-existing templates will need to be moved manually.

## Replacements
If you want to add your own replacements this is where you do it.
Replacements can be added by adding the following snippet to the `opts` table from the installation step.
```lua
...
opts = {
...
  replacements = {
    replacement_name = {
      from = "Hello",
      to = function(match)
        return "Goodbye"
      end,
    },
    ...
  },
...
},
...

```
The provided snippet replaces the string, "Hello", with the string, "Goodbye".
All of the inbuilt replacement strings are of the form, "{{__foo__}}" or "{{__bar__cmd__}}", but the plugin works with replacement strings of any form.
From is a string which will be matched on. 
Each occurance of the matched text will be replaced with the result of calling the function provided by `to`.
To is a function which takes a single string parameter.
The string provided is a copy of the matched text, not the pattern used to find the match.
This is very useful if you use wildcards in your `from` string.

For replacements which need to be performed after most normal replacements, the same snippet can be used replacing `replacements` with `post_replacements`.

For replacements which need to run before anything else replace `replacements` with `pre_replacements`.

For replacements which need to interact with the file in a manner more involved than simply modifying the files contents before they are written replace `replacements` with `cleanup_replacements`. 
Be aware, most replacements will work in one of the other three categories.
Cleanup replacements are meant for more meta tasks such as setting the users cursor position or running commands from other plugins which modify the buffers contents.
Additionally, the functions called for cleanup replacements are passed no arguments so removal of the replacement string must be done manually.

## Root Strategy
Some commands will need to find the root of your current project directory.
Several methods of this exist.
Most commonly, especially since Neovim now includes LSP support by default, is through an LSP server.
Five methods of finding the root directory of the project are included: all, lsp, git, marker, and none.
All will try all of them in the order: lsp, git, marker, none.
Lsp, git, and marker will simply use the provided method falling back to none if they are unsuccessful.
None will use the current directory, or the current working directory if the current buffer does not have a directory associated with it.
By default the "all" strategy is used but this can be changed by adding the following snippet to the `opts` table from the installation step.
```lua
...
opts = {
...
    -- Change this to one of the following: "all", "lsp", "git", "markers", "none"
    root_strategy = "all",
...
},
...
```

## Markers
When using the "markers" or "all" root strategy, a list of marker files will be used to determine where the project's root is.
No marker files are provided by default.
Marker files can be defined by adding the following snippet to the `opts` table from the installation step.
```lua
...
opts = {
...
    -- Replace fileN with the name of the file to use as a marker
    -- If multiple markers are defined, the first one encountered will be used
    markers = {
        "file1",
        "file2",
        "file3",
        ...
    },
...
},
...
```

## Intro
Sometimes, after creating or editing a template, you will be returned to your previous buffer.
In the case that no previous buffer exists, you are returned to the welcome screen.
By default this is `vim.cmd.intro()`.
To change this add the following snippet to the `opts` table from the installation step.
```lua
...
opts = {
...
    intro = function()
        -- Replace with the command to goto your welcome screen
        vim.cmd.Alpha() -- For alpha.nvim
    end,
...
},
...
```

## Ignore Dirs
Some directories should be ignored by default when searching for templates (e.g. .git, .venv, etc).
These directories can be defined using the `ignore_dirs` option.
By default the only directory which is ignored is `.git` however more can be added by adding the following snippet to the `opts` table from the installation step.
```lua
...
opts = {
...
    ignore_dirs = {
        ".git",
        ".venv",
        ...
    },
...
},
...
```
