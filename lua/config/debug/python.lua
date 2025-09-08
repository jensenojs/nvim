-- Python语言调试配置
-- 当前由 nvim-dap-python 接管 Python 的调试适配器与配置
-- 包含Adapter配置和Configuration配置
--[[
return {
	-- Adapter配置：定义如何启动debugpy调试器
	adapter = {
		type = "executable",
		command = "python3",
		args = { "-m", "debugpy.adapter" },
	},

	-- Configuration配置：定义Python语言的调试场景
	configurations = {
		{
			type = "python",
			name = "Launch File",
			request = "launch",
			program = require("utils.dap").fn.input_file_path(),
			cwd = "${workspaceFolder}",
			pythonPath = function()
				-- Handle virtual environments
				local venv = os.getenv("VIRTUAL_ENV")
				if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
					return venv .. "/bin/python"
				else
					return "python3"
				end
			end,
		},
		{
			type = "python",
			name = "Launch File with Args",
			request = "launch",
			program = require("utils.dap").fn.input_file_path(),
			args = require("utils.dap").fn.input_args(),
			cwd = "${workspaceFolder}",
			pythonPath = function()
				local venv = os.getenv("VIRTUAL_ENV")
				if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
					return venv .. "/bin/python"
				else
					return "python3"
				end
			end,
		},
		{
			type = "python",
			name = "Launch Module",
			request = "launch",
			module = function()
				return vim.fn.input("Module to debug: ")
			end,
			cwd = "${workspaceFolder}",
			pythonPath = function()
				local venv = os.getenv("VIRTUAL_ENV")
				if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
					return venv .. "/bin/python"
				else
					return "python3"
				end
			end,
		},
	},
}

]]

return {}