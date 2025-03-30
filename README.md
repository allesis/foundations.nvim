# Foundations
A templating plugin for the Neovim text editor.

## Features
- Easily create, edit, and manage templates
- Generate new files from templates quickly
- Simply templating syntax
- Extensible and customizable to your hearts content!

## Requirements
- Neovim >= 0.11.0 (As of now has not been tested on earlier versions, will update as it is)
- Telescope >= 0.1.8

## Installation
To install the plugin use the provided for your plugin manager of choice provided below.
Or you can rock a manual install.
Whatever works!
### Lazy (Suggested)
Just add the following to your lazy config and restart neovim.
```lua
-- lazy.nvim
-- or whatever file your plugins are listed in
...
{
  "allesis/foundations.nvim",
  opts = {
    -- Path where templates will be stored
    path = "~/.config/nvim/templates",
    -- Additional configuration options can be placed here
    -- To learn more see DOCS.md
  },
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
},
...
```

### Everything else
**TODO**
I may get around to it, who knows!

# Plans
- [ ] Project Templates
- [ ] Snippet Integration
- [ ] More Replacement String
