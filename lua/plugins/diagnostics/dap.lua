-- https://github.com/mfussenegger/nvim-dap
-- DAP核心插件配置
return {
	"mfussenegger/nvim-dap",
	main = "dap",
	dependencies = {
		{
			"rcarriga/nvim-dap-ui",
			lazy = true,
		},
		{
			"theHamsta/nvim-dap-virtual-text",
			lazy = true,
			opts = true,
		},
		{
			"LiadOz/nvim-dap-repl-highlights",
			lazy = true,
			opts = true,
		}, -- persistent-breakpoints is configured in its own spec to ensure early load on BufReadPost
		"nvim-neotest/nvim-nio",
        -- https://github.com/leoluz/nvim-dap-go
		"leoluz/nvim-dap-go",
	},
	keys = {
		{
			"<F5>",
			function()
				require("dap").continue()
			end,
			desc = "Debug: Start/Continue",
		},
		{
			"<F7>",
			function()
				require("dapui").toggle()
			end,
			desc = "Debug: See last session result.",
		},
		{
			"<F9>",
			function()
				require("persistent-breakpoints.api").toggle_breakpoint()
			end,
			desc = "Debug: Toggle Breakpoint (persistent)",
		},
		{
			"<F10>",
			function()
				require("dap").step_over()
			end,
			desc = "Debug: Step Over",
		},
		{
			"<F11>",
			function()
				require("dap").step_into()
			end,
			desc = "Debug: Step Into",
		},
		{
			"<F12>",
			function()
				require("dap").step_out()
			end,
			desc = "Debug: Step Out",
		},
		{
			"<leader>db",
			function()
				require("persistent-breakpoints.api").toggle_breakpoint()
			end,
			desc = "Debug: Toggle Breakpoint (persistent)",
		},
		{
			"<leader>dB",
			function()
				require("persistent-breakpoints.api").set_conditional_breakpoint()
			end,
			desc = "Debug: Set Conditional Breakpoint (persistent)",
		},
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Debug: Continue",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl()
			end,
			desc = "Debug: Open REPL",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "Debug: Terminate",
		},
	},

	opts = {
		go = {
			delve = {
				detached = vim.fn.has("win32") == 0,
			},
		},
	},
	config = function(_, opts)
		-- 保护 vim.ui.select, 避免 <C-c> 产生报错堆栈
		do
			local orig_select = vim.ui.select
			vim.ui.select = function(items, select_opts, on_choice)
				local ok = pcall(function()
					orig_select(items, select_opts, on_choice)
				end)
				if not ok and type(on_choice) == "function" then
					-- 静默取消
					on_choice(nil, nil)
				end
			end
		end

		local dap = require("dap")

		-- 配置调试适配器和语言配置
		require("config.debug").setup()

		-- 配置Go语言调试支持
		local ok_go, dap_go = pcall(require, "dap-go")
		if ok_go then
			dap_go.setup(opts.go)
		end
	end,
}
