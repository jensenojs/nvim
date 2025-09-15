-- https://github.com/daipeihust/im-select
local env = require("config.environment")

-- 只有在可执行文件可用时才加载插件
if env.has.im_select then
	return {
		-- should install im-select first, see
		"keaising/im-select.nvim",
		event = "InsertEnter",
		opts = true,
	}
else
	-- 如果 im-select 不可用，则不加载插件
	return {}
end
