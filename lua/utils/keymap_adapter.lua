--[[
模块: keymap_adapter

意图:
  为键位映射提供现代、可读的适配层, 统一使用 vim.keymap.set, 并提供 set/replace/amend 三种常见能力.
  真实代码提供中文注释, 覆盖文件头/函数级/关键语句级.

设计:
  - set: 直接设置映射, 要求提供 desc, 支持 buffer-local.
  - replace: 若已存在映射则先删除再设置, 避免多重绑定混淆.
  - amend: 在保留原映射作为 fallback 的情况下, 包装一个新的回调; 当新回调返回 false/nil 时, 自动执行原映射.

注意:
  - 为简化实现, 仅对单个 mode 采用明确 API; 多模式调用方可自行循环.
  - 读取已有映射时, 区分全局与 buffer-local.
]]

local M = {}

-- 小工具: 删除映射
local function del_map(mode, lhs, opts)
	opts = opts or {}
	local ok = pcall(function()
		if opts.buffer then
			vim.api.nvim_buf_del_keymap(0, mode, lhs)
		else
			vim.api.nvim_del_keymap(mode, lhs)
		end
	end)
	return ok
end

-- 小工具: 获取已有映射(仅取第一个匹配项)
local function get_map(mode, lhs, opts)
	opts = opts or {}
	local maps = {}
	if opts.buffer then
		maps = vim.api.nvim_buf_get_keymap(0, mode)
	else
		maps = vim.api.nvim_get_keymap(mode)
	end
	for _, m in ipairs(maps) do
		if m.lhs == lhs then
			return m
		end
	end
	return nil
end

-- 设置映射: 必须提供 desc 以提升可读性
function M.set(mode, lhs, rhs, opts)
	opts = opts or {}
	if not opts.desc then
		opts.desc = "(missing desc)"
	end
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- 替换映射: 若存在则先删除
function M.replace(mode, lhs, rhs, opts)
	opts = opts or {}
	if get_map(mode, lhs, opts) then
		del_map(mode, lhs, opts)
	end
	M.set(mode, lhs, rhs, opts)
end

-- 增补映射: 用新的回调包装旧映射, 新回调返回 false/nil 时触发旧映射
function M.amend(mode, lhs, new_cb, opts)
	opts = opts or {}
	local old = get_map(mode, lhs, opts)
	if not old then
		-- 无旧映射, 直接 set 新回调
		return M.set(mode, lhs, new_cb, opts)
	end

	-- 构造一个包装函数, 在新回调未“吞掉”事件时, 调用旧 rhs
	local wrapped = function(...)
		local ok, ret = pcall(new_cb, ...)
		if not ok then
			vim.notify("amend 回调报错: " .. tostring(ret), vim.log.levels.ERROR, { title = "keymap_adapter" })
			-- 报错时仍尝试回退
		end

		if ret == false or ret == nil then
			-- 回退: 尝试执行旧映射
			if type(old.callback) == "function" then
				return old.callback(...)
			elseif type(old.rhs) == "string" and old.rhs ~= "" then
				-- 执行一段普通模式命令串; 注意这可能不是 1:1 等价, 但作为兜底
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes(old.rhs, true, false, true),
					old.noremap and "n" or "m",
					true
				)
			end
		end

		return ret
	end

	opts.desc = (opts.desc or "") .. " (amend)"
	M.replace(mode, lhs, wrapped, opts)
end

return M
