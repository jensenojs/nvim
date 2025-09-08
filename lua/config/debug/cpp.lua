-- C/C++/Rust语言调试配置
-- 包含Adapter配置和Configuration配置
return {
	-- Adapter配置：定义如何启动CodeLLDB调试器
	adapter = {
		type = "server",
		port = "${port}",
		executable = {
			command = vim.fn.exepath("codelldb"),
			args = { "--port", "${port}" },
		},
	},

	-- Configuration配置：定义C/C++/Rust语言的调试场景
	configurations = {
		{
			type = "codelldb",
			name = "Launch Executable",
			request = "launch",
			program = function()
				return require("utils.dap").input_exec_path()
			end,
			args = function()
				return require("utils.dap").input_args()
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			runInTerminal = false,
		},
		{
			type = "codelldb",
			name = "Attach to Process (PID)",
			request = "attach",
			cwd = "${workspaceFolder}",
			processId = function()
				local filter = vim.fn.input("Filter process (lua pattern, empty for all): ")
				local opts = {}
				if type(filter) == "string" and #filter > 0 then
					opts.filter = filter
				end
				return require("dap.utils").pick_process(opts)
			end,
		},
		{
			type = "codelldb",
			name = "Attach: wait for program",
			request = "attach",
			program = function()
				return require("utils.dap").input_exec_path()
			end,
			cwd = "${workspaceFolder}",
			waitFor = true,
			stopOnEntry = false,
		},
	},
}
