arduino-helper.nvim
===

A Neovim plugin to help compile and upload arduino programs to Arduino boards using `arduino-cli`

## Requirements

- Neovim 0.7.0+
- (optional) [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## Install

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug "vlelo/arduino-helper.nvim" }
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

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

|      option        |      default value       |      explanation
| -------------------| ------------------------ | ---------
| `cli_command`      | `"arduino-cli"`          | The command to execute as arduino-cli, useful when the executable is not in the PATH
| `keep_nil_device`  | `true`                   | If `false`, arduino-helper will filter out devices wich don't report fqbn
| `ui`               | `"native"`               | What frontend to use for letting user choose devices or fqbns. Available options are:<br /><ul><li>`"native"`, which uses `vim.ui.select()`</li><li>`"telescope"`</li></ul>

## Usage

The plugin provides two commands, which are local to `.ino` buffers:

|     vimscript      |         lua                           |
| ------------------ | --------------------------------------|
| `:ArduinoCompile`  | `require("arduino-helper").compile()` |
| `:ArduinoUpload`   | `require("arduino-helper").upload()`  |
