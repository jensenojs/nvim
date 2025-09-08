--[[
模块: utils.palette

职责: 调色板与衍生高亮
- get_palette: 初始化并返回全局调色板(兼容 catppuccin, 支持 core.settings.palette_overwrite)
- gen_lspkind_hl: 为 LspKind* 生成默认颜色
- gen_alpha_hl: 为 alpha-nvim 生成标题/按钮/快捷键/页脚高亮
- gen_neodim_blend_attr: 为 neodim 生成 blend_color
]]

local color = require("utils.color")

---@type nil|table
local _palette = nil
---@type boolean
local _has_autocmd = false

local function init_palette()
	if not _has_autocmd then
		_has_autocmd = true
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("__builtin_palette", { clear = true }),
			pattern = "*",
			callback = function()
				_palette = nil
				init_palette()
			end,
		})
	end

	if not _palette then
		_palette = vim.g.colors_name
				and vim.g.colors_name:find("catppuccin")
				and require("catppuccin.palettes").get_palette()
			or {
				rosewater = "#DC8A78",
				flamingo = "#DD7878",
				mauve = "#CBA6F7",
				pink = "#F5C2E7",
				red = "#E95678",
				maroon = "#B33076",
				peach = "#FF8700",
				yellow = "#F7BB3B",
				green = "#AFD700",
				sapphire = "#36D0E0",
				blue = "#61AFEF",
				sky = "#04A5E5",
				teal = "#B5E8E0",
				lavender = "#7287FD",
				text = "#F2F2BF",
				subtext1 = "#BAC2DE",
				subtext0 = "#A6ADC8",
				overlay2 = "#C3BAC6",
				overlay1 = "#988BA2",
				overlay0 = "#6E6B6B",
				surface2 = "#6E6C7E",
				surface1 = "#575268",
				surface0 = "#302D41",
				base = "#1D1536",
				mantle = "#1C1C19",
				crust = "#161320",
			}

		_palette = vim.tbl_extend("force", { none = "NONE" }, _palette, require("core.settings").palette_overwrite)
	end

	return _palette
end

local M = {}

function M.get_palette(overwrite)
	if not overwrite then
		return init_palette()
	else
		return vim.tbl_extend("force", init_palette(), overwrite)
	end
end

function M.gen_lspkind_hl()
	local colors = M.get_palette()
	local dat = {
		Class = colors.yellow,
		Constant = colors.peach,
		Constructor = colors.sapphire,
		Enum = colors.yellow,
		EnumMember = colors.teal,
		Event = colors.yellow,
		Field = colors.teal,
		File = colors.rosewater,
		Function = colors.blue,
		Interface = colors.yellow,
		Key = colors.red,
		Method = colors.blue,
		Module = colors.blue,
		Namespace = colors.blue,
		Number = colors.peach,
		Operator = colors.sky,
		Package = colors.blue,
		Property = colors.teal,
		Struct = colors.yellow,
		TypeParameter = colors.blue,
		Variable = colors.peach,
		Array = colors.peach,
		Boolean = colors.peach,
		Null = colors.yellow,
		Object = colors.yellow,
		String = colors.green,
		TypeAlias = colors.green,
		Parameter = colors.blue,
		StaticMethod = colors.peach,
		Text = colors.green,
		Snippet = colors.mauve,
		Folder = colors.blue,
		Unit = colors.green,
		Value = colors.peach,
	}
	for kind, col in pairs(dat) do
		vim.api.nvim_set_hl(0, "LspKind" .. kind, { fg = col, default = true })
	end
end

function M.gen_alpha_hl()
	local colors = M.get_palette()
	vim.api.nvim_set_hl(0, "AlphaHeader", { fg = colors.blue, default = true })
	vim.api.nvim_set_hl(0, "AlphaButtons", { fg = colors.green, default = true })
	vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = colors.pink, italic = true, default = true })
	vim.api.nvim_set_hl(0, "AlphaFooter", { fg = colors.yellow, default = true })
end

function M.gen_neodim_blend_attr()
	local trans_bg = require("core.settings").transparent_background
	local appearance = require("core.settings").background
	if trans_bg and appearance == "dark" then
		return "#000000"
	elseif trans_bg and appearance == "light" then
		return "#FFFFFF"
	else
		return color.hl_to_rgb("Normal", true)
	end
end

return M
