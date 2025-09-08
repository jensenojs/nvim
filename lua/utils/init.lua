--[[
模块: utils.init

意图:
  提供颜色/高亮/调色板/配置的聚合导出, 并聚合工具模块: quick_substitute, bind, keymap_adapter, dap, icons。
]]

local color = require("utils.color")
local hl = require("utils.highlight")
local palette = require("utils.palette")
local cfg = require("utils.config")
local quick_substitute = require("utils.quick_substitute")
local bind = require("utils.bind")
local keymap_adapter = require("utils.keymap_adapter")
local icons = require("utils.icons")
local dap = require("utils.dap")
local health = require("utils.health")

local M = {}

-- 颜色能力
M.blend = color.blend
M.hl_to_rgb = color.hl_to_rgb

-- 高亮能力
M.extend_hl = hl.extend_hl

-- 调色板与主题相关能力
M.get_palette = palette.get_palette
M.gen_lspkind_hl = palette.gen_lspkind_hl
M.gen_alpha_hl = palette.gen_alpha_hl
M.gen_neodim_blend_attr = palette.gen_neodim_blend_attr

-- 配置与插件加载
M.tobool = cfg.tobool
M.extend_config = cfg.extend_config
M.load_plugin = cfg.load_plugin

-- 工具模块聚合
M.quick_substitute = quick_substitute
M.bind = bind
M.keymap_adapter = keymap_adapter
M.icons = icons
M.dap = dap
M.health = health

return M
