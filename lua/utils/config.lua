--[[
模块: utils.config

职责: 配置合并与插件加载
- tobool: 0/1 到 boolean
- extend_config: 合并用户配置
- load_plugin: 读取 user.configs.<fname> 做插件初始化
]]

local M = {}

function M.tobool(value)
	if value == 0 then
		return false
	elseif value == 1 then
		return true
	else
		vim.notify(
			"Attempting to convert data of type '" .. type(value) .. "' [other than 0 or 1] to boolean",
			vim.log.levels.ERROR,
			{ title = "[utils] Runtime Error" }
		)
		return nil
	end
end

-- 递归合并(对列表使用追加语义; table + function -> 执行函数取值)
local function tbl_recursive_merge(dst, src)
	for key, value in pairs(src) do
		if type(dst[key]) == "table" and type(value) == "function" then
			dst[key] = value()
		elseif type(dst[key]) == "table" and vim.tbl_islist(dst[key]) then
			vim.list_extend(dst[key], value)
		elseif type(dst[key]) == "table" and not vim.tbl_islist(dst[key]) then
			tbl_recursive_merge(dst[key], value)
		else
			dst[key] = value
		end
	end
	return dst
end

function M.extend_config(config, user_config)
	local ok, extras = pcall(require, user_config)
	if ok and type(extras) == "table" then
		config = tbl_recursive_merge(config, extras)
	end
	return config
end

--[[
函数: load_plugin(plugin_name, opts?, vim_plugin?, setup_callback?)
说明:
  - 若用户返回 false: 跳过该插件 setup
  - 若是 vimscript 插件: 用户须返回 function, 内部自己处理 vim.g 等
  - 否则: 合并/替换 opts 后调用 setup_callback 或 require(plugin_name).setup
]]
function M.load_plugin(plugin_name, opts, vim_plugin, setup_callback)
	vim_plugin = vim_plugin or false
	local fname = debug.getinfo(2, "S").source:match("[^@/\\]*.lua$")
	local ok, user_config = pcall(require, "user.configs." .. fname:sub(0, #fname - 4))

	if ok and vim_plugin then
		if user_config == false then
			return
		elseif type(user_config) == "function" then
			user_config()
		else
			vim.notify(
				string.format(
					"<%s> is not a typical Lua plugin, please return a function with\n"
						.. "the corresponding options defined instead (usually via `vim.g.*`)",
					plugin_name
				),
				vim.log.levels.ERROR,
				{ title = "[utils] Runtime Error (User Config)" }
			)
		end
		return
	end

	if not vim_plugin then
		if user_config == false then
			return
		end
		setup_callback = setup_callback or require(plugin_name).setup
		if ok then
			if type(user_config) == "table" then
				opts = tbl_recursive_merge(opts, user_config)
				setup_callback(opts)
			elseif type(user_config) == "function" then
				local user_opts = user_config()
				if type(user_opts) == "table" then
					setup_callback(user_opts)
				end
			else
				vim.notify(
					string.format(
						[[
Please return a `table` if you want to override some of the default options OR a
`function` returning a `table` if you want to replace the default options completely.

We received a `%s` for plugin <%s>.]],
						type(user_config),
						plugin_name
					),
					vim.log.levels.ERROR,
					{ title = "[utils] Runtime Error (User Config)" }
				)
			end
		else
			setup_callback(opts)
		end
	end
end

return M
