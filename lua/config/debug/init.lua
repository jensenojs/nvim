-- 调试配置初始化文件
-- 使用表驱动方式注册所有语言的Adapter和Configuration
local M = {}

function M.setup()
	local dap = require("dap")
	local registry = require("mason-registry")

	-- 定义支持的语言及其配置文件
	local language_configs = {
		c = {
			module = "config.debug.c",
			debugger = "codelldb",
		},
		cpp = {
			module = "config.debug.cpp",
			debugger = "codelldb",
		},
		rust = {
			module = "config.debug.rust",
			debugger = "codelldb",
		},
		-- python = {
		-- 	module = "config.debug.python",
		-- 	debugger = "debugpy",
		-- },
		-- python 由 nvim-dap-python 提供
		-- go 由 nvim-dap-go 提供
	}

	-- 表驱动方式注册所有语言的配置
	for lang, config_info in pairs(language_configs) do
		-- 检查调试器是否已安装
		if registry.is_installed(config_info.debugger) then
			-- 加载语言配置
			local ok, lang_config = pcall(require, config_info.module)
			if ok and lang_config then
				-- 注册Adapter配置(确保 adapters 的 key 与 configurations[*].type 一致)
				if lang_config.adapter then
					local adapter_key = lang
					if type(lang_config.configurations) == "table" then
						for _, cfg in ipairs(lang_config.configurations) do
							if type(cfg) == "table" and type(cfg.type) == "string" and #cfg.type > 0 then
								adapter_key = cfg.type
								break
							end
						end
					end
					dap.adapters[adapter_key] = lang_config.adapter
				end

				-- 注册Configuration配置
				if lang_config.configurations then
					dap.configurations[lang] = lang_config.configurations
				end
			else
				vim.notify("Failed to load debug configuration for " .. lang, vim.log.levels.WARN, {
					title = "Debug Config",
				})
			end
		else
			vim.notify(
				config_info.debugger
					.. " debugger not installed for "
					.. lang
					.. ". Please run :MasonInstall "
					.. config_info.debugger,
				vim.log.levels.WARN,
				{
					title = "Debug Config",
				}
			)
		end
	end
end

return M
