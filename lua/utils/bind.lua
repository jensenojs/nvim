--[[
模块: bind

职责:
  提供一个现代化、可读性强的键位绑定 DSL, 统一使用 `vim.keymap.set` 完成实际绑定。

接口:
  - 构造函数: map_cr/map_cmd/map_cu/map_args/map_callback
  - 链式修饰: with_silent/with_desc/with_noremap/with_expr/with_nowait/with_buffer
  - 批量加载: nvim_load_mapping(mapping), 其中 key 形如 "modes|lhs"

行为:
  - 若提供 callback 则建立函数映射, 否则使用字符串 rhs。
  - 当 buffer 为数字时创建 buffer-local 映射。
  - 不在 require 阶段产生副作用, 仅调用 nvim_load_mapping 或手动 set 时生效。
]]

local rhs_options = {}

function rhs_options:new()
	local instance = {
		cmd = "",
		options = {
			noremap = false,
			silent = false,
			expr = false,
			nowait = false,
			callback = nil,
			desc = "",
		},
		buffer = false, -- boolean|number, 与原版保持相同形态
	}
	setmetatable(instance, self)
	self.__index = self
	return instance
end

-- 直接映射字符串(不加 <CR>)
function rhs_options:map_cmd(cmd_string)
	self.cmd = cmd_string
	return self
end

-- 在命令前添加 ':' 并在尾部追加 <CR>
function rhs_options:map_cr(cmd_string)
	self.cmd = (":%s<CR>"):format(cmd_string)
	return self
end

-- 在命令后放一个空格, 用于等待用户继续输入参数
function rhs_options:map_args(cmd_string)
	self.cmd = (":%s<Space>"):format(cmd_string)
	return self
end

-- 消除可视模式下自动插入的范围(:<C-u>)
function rhs_options:map_cu(cmd_string)
	self.cmd = (":<C-u>%s<CR>"):format(cmd_string)
	return self
end

-- 使用回调作为 rhs
function rhs_options:map_callback(callback)
	self.cmd = ""
	self.options.callback = callback
	return self
end

function rhs_options:with_silent()
	self.options.silent = true
	return self
end

function rhs_options:with_desc(description_string)
	self.options.desc = description_string
	return self
end

function rhs_options:with_noremap()
	self.options.noremap = true
	return self
end

function rhs_options:with_expr()
	self.options.expr = true
	return self
end

function rhs_options:with_nowait()
	self.options.nowait = true
	return self
end

function rhs_options:with_buffer(num)
	self.buffer = num
	return self
end

local bind = {}

function bind.map_cr(cmd_string)
	local ro = rhs_options:new()
	return ro:map_cr(cmd_string)
end

function bind.map_cmd(cmd_string)
	local ro = rhs_options:new()
	return ro:map_cmd(cmd_string)
end

function bind.map_cu(cmd_string)
	local ro = rhs_options:new()
	return ro:map_cu(cmd_string)
end

function bind.map_args(cmd_string)
	local ro = rhs_options:new()
	return ro:map_args(cmd_string)
end

function bind.map_callback(callback)
	local ro = rhs_options:new()
	return ro:map_callback(callback)
end

-- 转义 termcode, 便于构造字符串 rhs
function bind.escape_termcode(cmd_string)
	return vim.api.nvim_replace_termcodes(cmd_string, true, true, true)
end

-- 载入映射表: key 形如 "nv|<leader>x", value 为 rhs_options
function bind.nvim_load_mapping(mapping)
	for key, value in pairs(mapping) do
		local modes, keymap = key:match("([^|]*)|?(.*)")
		if type(value) == "table" then
			for _, mode in ipairs(vim.split(modes, "")) do
				local rhs = value.options.callback or value.cmd
				local opts = vim.deepcopy(value.options)
				-- keymap.set 的 opts 不包含 callback 字段, 需移除
				opts.callback = nil
				-- buffer: 仅当为数字时生效
				if value.buffer and type(value.buffer) == "number" then
					opts.buffer = value.buffer
				end
				-- 若 rhs 为空字符串, 避免设置空映射
				if rhs ~= nil and rhs ~= "" then
					vim.keymap.set(mode, keymap, rhs, opts)
				end
			end
		end
	end
end

return bind
