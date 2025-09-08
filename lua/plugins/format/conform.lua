-- https://github.com/stevearc/conform.nvim
-- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#command-to-toggle-format-on-save
-- vim.api.nvim_create_user_command("FormatDisable", function(args)
--     if args.bang then
--         -- FormatDisable! will disable formatting just for this buffer
--         vim.b.disable_autoformat = true
--     else
--         vim.g.disable_autoformat = true
--     end
-- end, {
--     desc = "Disable autoformat-on-save",
--     bang = true
-- })
-- vim.api.nvim_create_user_command("FormatEnable", function()
--     vim.b.disable_autoformat = false
--     vim.g.disable_autoformat = false
-- end, {
--     desc = "Re-enable autoformat-on-save"
-- })
vim.api.nvim_create_user_command("FormatToggle", function(args)
	local conform = require("conform")
	local notify = require("notify")

	local show_notification = function(message, level)
		notify(message, level, {
			title = "conform.nvim",
		})
	end

	local is_global = not args.bang
	if is_global then
		vim.g.disable_autoformat = not vim.g.disable_autoformat
		if vim.g.disable_autoformat then
			show_notification("Autoformat-on-save disabled globally", "info")
		else
			show_notification("Autoformat-on-save enabled globally", "info")
		end
	else
		vim.b.disable_autoformat = not vim.b.disable_autoformat
		if vim.b.disable_autoformat then
			show_notification("Autoformat-on-save disabled for this buffer", "info")
		else
			show_notification("Autoformat-on-save enabled for this buffer", "info")
		end
	end
end, {
	desc = "Toggle autoformat-on-save",
	bang = true,
})

return {
	"stevearc/conform.nvim",

	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			"<cmd>ConformFormatModified<CR>",
			mode = "n",
			desc = "格式化 : 仅修改的部分",
		},
		{
			"<leader>F",
			function()
				require("conform").format({
					async = true,
				})
			end,
			mode = "n",
			desc = "格式化 : 整个文件",
		},
	},

	init = function()
		-- Format only modified hunks using LSP range formatting; fallback to conform full format
		vim.api.nvim_create_user_command("ConformFormatModified", function()
			local ok, fm = pcall(require, "utils.format_modified")
			if ok then
				fm.format_modified({
					fallback = "conform",
				})
			else
				local okc, conform = pcall(require, "conform")
				if okc then
					conform.format({
						async = true,
					})
				else
					vim.lsp.buf.format({
						async = true,
					})
				end
			end
		end, {})
	end,

	---@module "conform"
	---@type conform.setupOpts
	opts = {
		-- 与 guard.nvim 等价的链式格式化映射
		formatters_by_ft = {
			json = { "jq" },
			sh = { "shfmt" },
			python = function(bufnr)
				local conform = require("conform")
				if conform.get_formatter_info("ruff_format", bufnr).available then
					return { "ruff_format" }
				else
					return { "isort", "black" }
				end
			end,
			c = { "clang-format" },
			cpp = { "clang-format" },
			go = { "goimports", "gofmt" },
			rust = { "rustfmt" },
			sql = { "sqlfmt" },
			lua = { "stylua" },
			["_"] = { "trim_whitespace" },
		},

		-- 默认使用 LSP 作为兜底, 与原先 guard(fmt_on_save=false) 的交互相近
		default_format_opts = {
			lsp_format = "fallback",
		},

		-- 可选: 自定义单个 formatter 参数
		formatters = {
			shfmt = {
				append_args = { "-i", "2" },
			},
		},

		-- If this is set, Conform will run the formatter on save.
		-- It will pass the table to conform.format().
		-- This can also be a function that returns the table.
		format_on_save = function(bufnr)
			-- Disable with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return {
				timeout_ms = 500,
				lsp_fallback = true,
			}
		end,
		-- format_on_save = function(bufnr)
		--     -- Disable with a global or buffer-local variable
		--     if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
		--         return
		--     end
		--     return {
		--         timeout_ms = 500,
		--         lsp_format = "fallback"
		--     }
		-- end,
	},
}
