--[[
模块: utils.color

职责: 颜色基础能力
- blend: 前景/背景颜色按 alpha 混合
- hl_to_rgb: 从高亮组读取前景/背景色
]]

local M = {}

-- 内部工具: 将 #RRGGBB 转为 {r,g,b}
local function hex_to_rgb(c)
	c = string.lower(c)
	return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

--[[
函数: blend(foreground, background, alpha)
参数:
  foreground: string, #RRGGBB
  background: string, #RRGGBB
  alpha: number|string, 若为字符串, 按 16 进制 0x00..0xff 转 0..1
返回:
  string, #RRGGBB
]]
function M.blend(foreground, background, alpha)
	alpha = type(alpha) == "string" and (tonumber(alpha, 16) / 0xff) or alpha
	local bg = hex_to_rgb(background)
	local fg = hex_to_rgb(foreground)

	local function blend_channel(i)
		local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
		return math.floor(math.min(math.max(0, ret), 255) + 0.5)
	end

	return string.format("#%02x%02x%02x", blend_channel(1), blend_channel(2), blend_channel(3))
end

--[[
函数: hl_to_rgb(hl_group, use_bg, fallback_hl?)
说明:
  读取高亮组前景或背景色, 未定义则返回 fallback 或 "#000000"/"NONE"。
]]
function M.hl_to_rgb(hl_group, use_bg, fallback_hl)
	local hex = fallback_hl or "#000000"
	local hlexists = pcall(vim.api.nvim_get_hl, 0, { name = hl_group, link = false })
	if hlexists then
		local result = vim.api.nvim_get_hl(0, { name = hl_group, link = false })
		if use_bg then
			hex = result.bg and string.format("#%06x", result.bg) or "NONE"
		else
			hex = result.fg and string.format("#%06x", result.fg) or "NONE"
		end
	end
	return hex
end

return M
