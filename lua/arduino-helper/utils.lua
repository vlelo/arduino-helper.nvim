local M = {}

--- Uses arduino-cli to retrieve a list of devices
---@param cli_command string The command to use
---@param keep_nil_device boolean Wether to keep ports with no boards attached
---@return table ports A table containing the devices found, which each contains the following fields:
---         - port string The name of the port
---         - fqbn string The FQBN of the device attached to the port. Is nil if no device is attached
---Return value is nil if no device is found
function M.get_devices(cli_command, keep_nil_device)
	local f = assert(io.popen(cli_command .. " board list", "r"))
	local s = assert(f:read("*a"))
	f:close()
	-- At this point s contains the whole arduino-cli output

	-- ports_tmp contains in each index a line of the output
	local ports_tmp = vim.split(s, "\n", false)
	local ports = {}

	-- arduino-cli board list
	-- leaves some empty lines in it's output, this removes them by
	-- checking for an empty line pattern
	for i, v in ipairs(ports_tmp) do
		if string.match(v, "^%s*$") ~= nil then
			ports_tmp[i] = nil
		end
	end

	-- fqbn_pos contains the position of the FQBN column, to then allow
	-- to look for fqbns
	local fqbn_pos = string.find(ports_tmp[1], "FQBN")

	-- Remove the first element, which contains just the legend of the
	-- output, and check if no devices were found
	table.remove(ports_tmp, 1)
	if #ports_tmp == 0 then
		-- vim.notify("No devices found.", vim.log.levels.ERROR)
		return nil
	end

	-- Create the ports table by iterating the ports_temp table
	for _, device in ipairs(ports_tmp) do
		table.insert(ports, {})
		-- port filed is guaranteed to exist and be at the beginning
		ports[#ports].port = string.match(device, "^[^%s]*")
		-- fqbn filed must be a single non space string and must be found
		-- by starting the search at the fqbn_pos position, as space is
		-- not an accurate delimiter for the output of arduino-cli
		ports[#ports].fqbn = string.match(device, "[^%s]*", fqbn_pos)
		-- if no device is attached to the port, the match is an empty
		-- string. Make it so that the value is nil instead
		if ports[#ports].fqbn == "" then
			if keep_nil_device then
				ports[#ports].fqbn = nil
			else
				ports[#ports] = nil
			end
		end
	end

	return ports
end

--- Prompt user to choose the device
---@param devices table The devices obtained from utils.get_devices()
---@param ui string What kind of ui to use
---@param caller string What functino called select_device()
local function ui_choice(devices, ui, caller)
	if ui == "native" then
		vim.ui.select(
			devices,
			{
				prompt = "Select port to upload to:",
				format_item = function(item)
					return (item.fqbn or "Could not detect device") .. " on port " .. item.port
				end,
				kind = "table",
			},
			--[[
				For some reason, here vim.ui.select() executes in async, and thus there
				are some problems with executions down the line.
				For this reason caller is used to call without bang the function, so that
				the final comand may be executed.
			--]]
			function(item, _)
				if item then
					vim.b.arduino_helper_port = item.port
					vim.b.arduino_helper_fqbn = item.fqbn
				end
				require("arduino-helper")[caller]()
		end)
	elseif ui == "telescope" then
		error("Telescope UI not implemented")
	end
end

--- Set the buffer variables that rappreset the device to upload or
-- compile to. If more than one devices are available, prompt the
-- user to make a choice
---@param cli_command string|nil The command to use
---@param keep_nil_device boolean Wether to keep ports with no boards attached
---@param ui string What kind of ui to use
---@param caller string What functino called select_device()
function M.select_device(cli_command, keep_nil_device, ui, caller)
	local devices = M.get_devices(cli_command, keep_nil_device)

	if #devices == 0 then
	-- no devices available, abort operation
		vim.notify("[arduino-helper] ERROR: no devies available", vim.log.levels.ERROR)
		return 1
	elseif #devices == 1 then
	-- only one device, no choice to be made
		vim.b.arduino_helper_port = devices[1].port
		vim.b.arduino_helper_fqbn = devices[1].fqbn
		return 0
	else
		-- ui_choice calls the caller function, because it executes asyncronous code
		-- thus when allowing a choice, always return 1
		ui_choice(devices, ui, caller)
		return 1
	end
end

return M
