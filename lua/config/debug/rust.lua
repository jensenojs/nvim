-- Rust 语言调试配置(基于 CodeLLDB)
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

	-- Rust 的调试场景
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
			-- 可选：针对 Rust 的 LLDB pretty-printers / 初始化命令(按需启用)
			-- 注意：以下示例依赖 `rustc --print sysroot` 可用, 且路径下存在 `lldb_lookup.py`
			-- 如果你的 codelldb 已内置较好的 Rust 显示, 可仅保留 `settings set target.language rust`
			-- initCommands = (function()
			--   local ok, sysroot = pcall(function()
			--     return vim.fn.trim(vim.fn.system('rustc --print sysroot'))
			--   end)
			--   local cmds = { 'settings set target.language rust' }
			--   if ok and type(sysroot) == 'string' and #sysroot > 0 then
			--     local script = sysroot .. '/lib/rustlib/etc/lldb_lookup.py'
			--     if vim.fn.filereadable(script) == 1 then
			--       table.insert(cmds, 'command script import "' .. script .. '"')
			--     end
			--   end
			--   return cmds
			-- end)(),
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
