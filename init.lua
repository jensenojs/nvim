require("config.environment")

-- 环境特征可选打印, 便于调试
local ok_env, env = pcall(require, "config.environment")
if ok_env and not vim.g.__tmp_env_printed then
	vim.g.__tmp_env_printed = true
	vim.schedule(function()
		vim.notify("[config.environment] => " .. env.summary(), vim.log.levels.INFO, { title = "tmp/init" })
	end)
end
require("config.keymaps")
require("config.options")
require("config.autocmds")
require("config.lsp.bootstrap")
require("config.lazy")
