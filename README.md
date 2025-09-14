# keep.nvim

A simple floating note-taking plugin for Neovim.

## Features

- Opens a floating window for quick note-taking
- Persistent notes saved to a configurable location
- Markdown syntax highlighting
- Easy access with `<leader>kn`
- Auto-saves on `:wq` and closes the floating window

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "yourusername/keep.nvim",
  config = function()
    require('keep').setup({
      -- Optional: customize the notes file location
      notes_file = "~/Documents/notes.md",
      
      -- Optional: customize floating window appearance
      float_opts = {
        width = 100,
        height = 30,
        border = "double",
      }
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'yourusername/keep.nvim',
  config = function()
    require('keep').setup()
  end
}
```

## Configuration

Default configuration:

```lua
require('keep').setup({
  notes_file = vim.fn.expand("~/.config/nvim/notes.md"),
  float_opts = {
    relative = "editor",
    width = 80,
    height = 24,
    border = "rounded",
    title = " Notes ",
    title_pos = "center",
  }
})
```

## Usage

- Press `<leader>kn` to open/toggle the floating notes window
- Type your notes (markdown syntax highlighting included)
- Use `:w` to save your notes
- Use `:wq` or `:q` to save and close the window
- Press `<Esc>` or `q` in normal mode to close without explicit save command

## Commands

The plugin automatically creates the keymap `<leader>kn`. You can also call the functions directly:

```vim
:lua require('keep').open_notes()
:lua require('keep').close_notes()
```

## Customization

You can override any of the default settings:

```lua
require('keep').setup({
  notes_file = "~/my-notes/quick-notes.md",
  float_opts = {
    width = 120,
    height = 40,
    border = "single",
    title = " My Notes ",
    -- Any nvim_open_win options work here
  }
})
```
