-- 最终版本
return {
	"williamboman/mason.nvim",
	cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
	opts = function()
		local env = require("config.environment")
		local pip_args = env.pip_proxy and { "--proxy", env.pip_proxy } or {}
		return {
			pip = {
				upgrade_pip = false,
				install_args = pip_args,
			},
		}
	end,
	init = function()
		-- 自动安装逻辑
		local env = require("config.environment")
		if env.offline then
			return
		end

		vim.defer_fn(function()
			local ok, utils = pcall(require, "utils.mason-list")
			if not ok then
				return
			end

			local tools = utils.tools()
			local ok_reg, registry = pcall(require, "mason-registry")
			if not ok_reg then
				return
			end

			for _, name in ipairs(tools) do
				local ok_pkg, pkg = pcall(registry.get_package, name)
				if ok_pkg and not pkg:is_installed() then
					pkg:install()
				end
			end
		end, 100)
	end,
}
