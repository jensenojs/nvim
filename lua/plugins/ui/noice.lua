-- https://github.com/folke/noice.nvim
-- 目的: 基于 lazy.nvim 的懒加载方式, 现代化命令行/消息/LSP UI
return {
	"folke/noice.nvim",
	event = "UIEnter",
	main = "noice",
	-- 在插件加载前定义按键, 自动探测是否处于 Noice LSP 文档环境
	init = function()
		local function map_scroll(lhs, delta)
			vim.keymap.set({ "n", "i", "s" }, lhs, function()
				local ok_scroll = pcall(function()
					return require("noice.lsp").scroll(delta)
				end)
				if not ok_scroll or not require("noice.lsp").scroll(delta) then
					return lhs
				end
			end, {
				expr = true,
				silent = true,
				desc = "Noice LSP 文档滚动",
			})
		end
		map_scroll("<C-f>", 4)
		map_scroll("<C-b>", -4)
	end,
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
		{
			-- https://github.com/rcarriga/nvim-notify
			"rcarriga/nvim-notify",
			event = "VeryLazy",
			opts = {
				stages = "fade_in_slide_out",
				timeout = 300,
				fps = 60,
				level = vim.log.levels.INFO,
				-- background_colour = "NotifyBackground",
				background_colour = "#000000",
				top_down = true,
			},
			config = function(_, opts)
				local ok, notify = pcall(require, "notify")
				if ok then
					notify.setup(opts)
					vim.notify = notify
				end
			end,
		},
	},
	---@type NoiceConfig
	opts = {
		presets = {
			command_palette = true,
			lsp_doc_border = true,
			bottom_search = false,
			long_message_to_split = false,
			inc_rename = true,
		},
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
			format = {
				cmdline = {
					pattern = "^:",
					icon = require("utils.icons").get("ui").Cmdline,
					lang = "vim",
				},
				search_down = {
					kind = "search",
					pattern = "^/",
					icon = require("utils.icons").get("ui").SearchDown,
					lang = "regex",
				},
				search_up = {
					kind = "search",
					pattern = "^%?",
					icon = require("utils.icons").get("ui").SearchUp,
					lang = "regex",
				},
			},
		},
		messages = {
			enabled = true,
			view = "notify",
			view_error = "notify",
			view_warn = "notify",
			view_history = "popup",
			view_search = false,
		},
		popupmenu = {
			enabled = true,
			-- 默认使用 nui 后端, 避免在 tmp 中耦合 nvim-cmp
			backend = "nui",
		},
		notify = {
			enabled = true,
			view = "notify",
		},
		lsp = {
			progress = {
				enabled = false,
			},
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
			hover = {
				enabled = true,
				silent = true,
			},
			signature = {
				enabled = true,
				auto_open = {
					enabled = true,
					trigger = false,
					throttle = 50,
				},
			},
			message = {
				enabled = true,
				view = "mini",
			},
			documentation = {
				view = "hover",
				opts = {
					lang = "markdown",
					replace = true,
					render = "plain",
					format = { "{message}" },
					win_options = {
						concealcursor = "n",
						conceallevel = 3,
					},
				},
			},
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "written",
				},
				opts = {
					skip = true,
				},
			},
		},
	},
}
