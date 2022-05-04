local M = {}

--- Set the plugins options in opts from options table opts
---@param setopts table Table to get options from
---@param opts table Table to set options to, which already has defaults
function M.set_opts(setopts, opts)
	for opt, opt_value in pairs(opts) do
		if setopts[opt] == nil then
			opt_value.value = opt_value.default
		else
			if type(setopts[opt]) ~= opt_value.type then
				vim.notify("[arduino-helper] WARN: invalid type for option: '" .. opt .. "'" ..
									 " | Expected '" .. opt_value.type .. "' got '" .. type(setopts[opt]) .. "'",
					vim.log.levels.WARN)

			-- not opt_value.values: true if is nil, which means that opt can have any value
			-- if not opt_value.values is false, then opt can have only a predetermined
			-- set of values, contained in value.values.
			-- vim.tbl_contains(opt_value.values, setopts[opt]) is true if setopts[opt] is a valid
			-- value of opt_value.
			elseif not opt_value.values or vim.tbl_contains(opt_value.values, setopts[opt]) then
				opt_value.value = setopts[opt]
			else
				vim.notify("[arduino-helper] WARN: invalid value for option: '" .. opt .. " = " .. setopts[opt] .. "'", vim.log.levels.WARN)
			end

			setopts[opt] = nil
		end
	end

	for opt, _ in pairs(setopts) do
		vim.notify("[arduino-helper] WARN: unrecognised option: '" .. opt .. "'", vim.log.levels.WARN)
	end

	return opts
end

return M
