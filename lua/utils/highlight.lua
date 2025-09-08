--[[
模块: utils.highlight

职责: 高亮扩展
- extend_hl: 在保持现有属性的前提下, 追加/覆盖部分字段
]]

local M = {}

--[[
函数: extend_hl(name, def)
说明:
  若高亮组存在, 读取其当前定义, 与 def 深度合并后回写。
]]
function M.extend_hl(name, def)
	local hlexists = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	if not hlexists then
		return
	end
	local current_def = vim.api.nvim_get_hl(0, { name = name, link = false })
	local combined_def = vim.tbl_deep_extend("force", current_def, def)
	vim.api.nvim_set_hl(0, name, combined_def)
end

return M
