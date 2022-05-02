local M = {}

--- Set the plugins options in opts from options table opts
---@param setopts table Table to get options from
---@param opts table Table to set options to, which already has defaults
function M.set_opts(setopts, opts)
	for opt, value in pairs(setopts) do
		if opts[opt] == nil then
			vim.notify("[arduino-helper] WARN: unrecognised option: '" .. opt .. "'", vim.log.levels.WARN)
		elseif type(value) ~= opts[opt].type then
			vim.notify("[arduino-helper] WARN: invalid type for option: '" .. opt .. "'" ..
			           " | Expected '" .. opts[opt].type .. "' got '" .. type(value) .. "'",
				vim.log.levels.WARN)

		-- not opts[opt].values: true if is nil, which means that opt can have any value
		-- if not opts[opt].values is false, then opt can have only a predetermined
		-- set of values, contained in opts[opt].values.
		-- vim.tbl_contains(opts[opt].values, value) is true if value is a valid
		-- value of opt.
		elseif not opts[opt].values or vim.tbl_contains(opts[opt].values, value) then
			opts[opt].value = value
		else
			vim.notify("[arduino-helper] WARN: invalid value for option: '" .. opt .. " = " .. value .. "'", vim.log.levels.WARN)
		end
	end

	return opts
end

return M
