arduino-helper.nvim
===

A Neovim plugin to help compile and upload arduino programs to Arduino boards using `arduino-cli`

## Requirements

- Neovim 0.7.0+
- (optional) [telescope.nvim][telescope.nvim] 

## Install

Using [vim-plug][vim-plug]:

```vim
Plug "vlelo/arduino-helper.nvim" }
```

Using [packer.nvim][packer]:

```lua
use { "vlelo/arduino-helper.nvim" }
```

## Setup

For most users, default configs with *Telescope* support will be satisfying:

```lua
require("arduino-helper").setup{
	ui = "telescope",
}
```

### Setup options

When calling the `setup` function, the following options are available:

|      option      |      default value     |      
| -----------------| ---------------------- |
| cli_command      | "arduino-cli"          |
| keep_nil_device  | true                   |
| ui               | "native"               |
