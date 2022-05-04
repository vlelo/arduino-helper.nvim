local M = {}

M.var_name = "_arduino_helper"

function M.bsa(val)
	vim.api.nvim_buf_set_var(0, M.var_name, val)
end

function M.bga()
	return vim.api.nvim_buf_get_var(0, M.var_name)
end

function M.bda()
	vim.api.nvim_buf_del_var(0, M.var_name)
end

return M
