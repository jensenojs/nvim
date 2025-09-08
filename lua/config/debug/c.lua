-- C 语言调试配置(基于 CodeLLDB)
-- adapter 与 configurations 的 `type` 使用 "codelldb", 与 nvim-dap 的匹配规则一致
return {
	-- Adapter 配置：启动 CodeLLDB 调试服务器, 使用动态端口
	adapter = {
		type = "server",
		port = "${port}",
		executable = {
			command = vim.fn.exepath("codelldb"),
			args = { "--port", "${port}" },
		},
	},

	-- C 的调试场景
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
