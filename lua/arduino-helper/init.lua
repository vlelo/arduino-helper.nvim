local utils = require("arduino-helper.utils")
local opts = require("arduino-helper.opts")

local plugin_opts = {
	cli_command = {
		name = "cli_command",
		value = "arduino-cli",
		type = "string",
		values = nil,
	},
	keep_nil_device = {
		name = "keep_nil_device",
		value = false,
		type = "boolean",
		values = nil,
	},
	ui = {
		name = "ui",
		value = "native",
		type = "string",
		values = {
			"native",
			"telescope",
		},
	}
}

local M = {}

local function upload(lopts)
	return function(attr)
		if (attr and attr.bang) or (not vim.b.arduino_helper_port and not vim.b.arduino_helper_fqbn) then
			if utils.select_device(lopts.cli_command.value, lopts.keep_nil_device.value, lopts.ui.value, "upload") == 1 then
				return 1
			end
		end

		if vim.b.arduino_helper_port and vim.b.arduino_helper_fqbn then
			vim.cmd("!" .. lopts.cli_command.value .. " upload --port " .. vim.b.arduino_helper_port .. " --fqbn " .. vim.b.arduino_helper_fqbn .. " %")
		end
	end
end

local function compile(lopts)
	return function(attr)
		if (attr and attr.bang) or not vim.b.arduino_helper_fqbn then
			if utils.select_device(lopts.cli_command.value, lopts.keep_nil_device.value, lopts.ui.value, "compile") == 1 then
				return 1
			end
		end

		if vim.b.arduino_helper_fqbn then
			vim.cmd("!" .. lopts.cli_command.value .. " compile --fqbn " .. vim.b.arduino_helper_fqbn .. " %")
		end
	end
end

local command_opts = {
	bang = true,
}

function M.setup(setopts)
	if setopts then plugin_opts = opts.set_opts(setopts, plugin_opts) end

	M.upload = upload(plugin_opts)
	M.compile = compile(plugin_opts)

	vim.api.nvim_create_augroup("arduino-helper", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType "}, {
		group = "arduino-helper",
		pattern = "arduino",
		desc = "Create arduino-helper local commads when enterino .ino buffer",
		callback = function()
			vim.api.nvim_buf_create_user_command(0, "ArduinoUpload", M.upload, command_opts)
			vim.api.nvim_buf_create_user_command(0, "ArduinoCompile", M.compile, command_opts)
		end,
	})
end

return M
