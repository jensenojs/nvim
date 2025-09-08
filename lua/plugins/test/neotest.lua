-- https://github.com/nvim-neotest/neotest
local bind = require("utils.bind")
local map_callback = bind.map_callback
local map_cr = bind.map_cr
local map_cmd = bind.map_cmd

local get_file_path = function()
	return vim.fn.expand("%")
end
local get_project_path = function()
	return vim.fn.getcwd()
end

local keymaps = {
	["n|<space>tn"] = map_callback(function()
			require("neotest").run.run()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("neotest : run nearest"),

	["n|<space>td"] = map_callback(function()
			require("neotest").run.run({ strategy = "dap" })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("neotest : debug nearest"),

	["n|<space>tf"] = map_callback(function()
			require("neotest").run.run(get_file_path())
		end)
		:with_noremap()
		:with_silent()
		:with_desc("neotest : run file"),

	["n|<space>ts"] = map_callback(function()
			require("neotest").summary.toggle()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("neotest : toggle summay"),

	["n|<space>to"] = map_callback(function()
			require("neotest").output.open({ enter = true, auto_close = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("neotest : show output"),

	["n|<space>tw"] = map_callback(function()
			require("neotest").watch.toggle()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("neotest : toggle watch"),

	["n|<space>tW"] = map_callback(function()
			require("neotest").watch.toggle(get_file_path())
		end)
		:with_noremap()
		:with_silent()
		:with_desc("neotest : toggle watch all test in file"),

	["n|<space>tA"] = map_callback(function()
			require("neotest").run.run(get_project_path())
		end)
		:with_noremap()
		:with_silent()
		:with_desc("neotest : run all test files"),

	["n|<space>tO"] = map_callback(function()
			require("neotest").output_panel.toggle()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("neotest : toggle output panel"),

	["n|<space>tS"] = map_callback(function()
			require("neotest").run.stop()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("neotest : Stop"),
}

bind.nvim_load_mapping(keymaps)

return {
	"nvim-neotest/neotest",
	lazy = true,
	ft = { "go", "rust", "c", "cpp", "python" },
	-- 通过 require("neotest") 等自动懒加载
	module = { "neotest", "neotest-golang", "neotest-gtest", "neotest-python" },
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		{ "fredrikaverpil/neotest-golang", version = "*" },
		"alfaix/neotest-gtest",
		"nvim-neotest/neotest-python",
	},
	opts = {
		adapters = {
			-- Go
			["neotest-golang"] = {
				go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
				dap_go_enabled = true,
			},
			-- C/C++ (GoogleTest)
			["neotest-gtest"] = {},
			-- Python (pytest)
			["neotest-python"] = {
				runner = "pytest",
			},
			-- Rust
			["rustaceanvim.neotest"] = {},
		},
		status = { virtual_text = true },
		output = { open_on_run = true },
		quickfix = {
			open = function()
					vim.cmd("copen")
			end,
		},
	},
	config = function(_, opts)
		local neotest_ns = vim.api.nvim_create_namespace("neotest")
		vim.diagnostic.config({
			virtual_text = {
				format = function(diagnostic)
					-- Replace newline and tab characters with space for more compact diagnostics
					local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
					return message
				end,
			},
		}, neotest_ns)

		opts.consumers = opts.consumers or {}
		opts.consumers.trouble = function(client)
			client.listeners.results = function(adapter_id, results, partial)
				if partial then
					return
				end
				local tree = assert(client:get_position(nil, { adapter = adapter_id }))

				local failed = 0
				for pos_id, result in pairs(results) do
					if result.status == "failed" and tree:get_key(pos_id) then
						failed = failed + 1
					end
				end
				vim.schedule(function()
					local ok_trouble, trouble = pcall(require, "trouble")
					if ok_trouble and trouble.is_open() then
						trouble.refresh()
						if failed == 0 then
							trouble.close()
						end
					end
				end)
				return {}
			end
		end

		if opts.adapters then
			local adapters = {}
			for name, config in pairs(opts.adapters or {}) do
				if type(name) == "number" then
					if type(config) == "string" then
						config = require(config)
					end
					adapters[#adapters + 1] = config
				elseif config ~= false then
					local ok_adapter, adapter = pcall(require, name)
					if not ok_adapter then
						-- 对于未安装的适配器, 直接跳过
						goto continue
					end
					if type(config) == "table" and not vim.tbl_isempty(config) then
						local meta = getmetatable(adapter)
						if adapter.setup then
							adapter.setup(config)
						elseif adapter.adapter then
							adapter.adapter(config)
							adapter = adapter.adapter
						elseif meta and meta.__call then
							adapter(config)
						else
							error("Adapter " .. name .. " does not support setup")
						end
					end
					adapters[#adapters + 1] = adapter
				end
				::continue::
			end
			opts.adapters = adapters
		end

		require("neotest").setup(opts)
	end,
}
