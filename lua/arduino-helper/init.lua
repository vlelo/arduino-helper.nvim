local devices = require("arduino-helper.devices")
local opts = require("arduino-helper.opts")
local utils = require("arduino-helper.utils")

local plugin_opts = {
	cli_command = {
		name = "cli_command",
		value = nil,
		default = "arduino-cli",
		type = "string",
		values = nil,
	},
	keep_nil_device = {
		name = "keep_nil_device",
		value = nil,
		default = true,
		type = "boolean",
		values = nil,
	},
	ui = {
		name = "ui",
		value = nil,
		default = "native",
		type = "string",
		values = {
			"native",
			"telescope",
		},
	}
}

local M = {}

local function upload(lopts)
	local command = "upload"
	return function(attr)
		local device_stats = utils.bga()

		if (attr and attr.bang) or not device_stats.port or not device_stats.fqbn then
			if not device_stats.port then
				if devices.select_device(lopts.cli_command.value, lopts.keep_nil_device.value, lopts.ui.value, command) == 1 then
					return 1 -- error
				end
				return require("arduino-helper")[command]()
			else
				vim.notify("No device detected on the port", vim.log.levels.INFO)
				if devices.select_fqbn(lopts.cli_command.value, lopts.ui.value, command) == 1 then
					return 1 -- error
				end
			end
		end

		if device_stats.port and device_stats.fqbn then
			-- strip spaces from end of port string
			device_stats.port = string.gsub(device_stats.port, "%s*$", "")
			vim.cmd("!" .. lopts.cli_command.value .. " upload --port " .. device_stats.port .. " --fqbn " .. device_stats.fqbn .. " %")
		end

		return 2 -- no operation done
	end
end

local function compile(lopts)
	local command = "compile"
	return function(attr)
		local device_stats = utils.bga()

		if (attr and attr.bang) or not device_stats.fqbn then
			if not device_stats.port then
				if devices.select_device(lopts.cli_command.value, lopts.keep_nil_device.value, lopts.ui.value, command) == 1 then
					return 1 -- error
				end
				return require("arduino-helper")[command]()
			else
				vim.notify("No device detected on the port", vim.log.levels.INFO)
				if devices.select_fqbn(lopts.cli_command.value, lopts.ui.value, command) == 1 then
					return 1 -- error
				end
			end
		end

		if device_stats.fqbn then
			vim.cmd("!" .. lopts.cli_command.value .. " compile --fqbn " .. device_stats.fqbn .. " %")
			return 0 -- success
		end

		return 2 -- no operation done
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
			utils.bsa({})
			vim.api.nvim_buf_create_user_command(0, "ArduinoUpload", M.upload, command_opts)
			vim.api.nvim_buf_create_user_command(0, "ArduinoCompile", M.compile, command_opts)
		end,
	})
end

function M.print_opts()
	print(vim.inspect(plugin_opts))
end

return M
