-- telescope LSP buffer takeover helpers
-- 负责在带 LSP 的 buffer 上用 Telescope 覆盖部分按键
local M = {}

local bind = require("utils.bind")
local map_callback = bind.map_callback
local api = vim.api

-- 内部: 判断 bufnr 是否有效且已附加 LSP
local is_lsp_attached = require("utils.lsp").is_lsp_attached

-- 在 LSP buffer 上用 Telescope 覆盖部分键位
-- 只演示两键: <leader>o (document symbols), <leader>O (workspace symbols)
-- 注意：这里只使用 telescope 的内置 LSP 系列入口(telescope.builtin.lsp_*),
-- 参考文档：https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt
-- 这样可以保证行为统一到 Telescope 的 UI, 不与原生 vim.lsp.buf.* 重复实现。
function M.takeover_lsp_buf(bufnr, client)
	local if_support = function(method)
		return require("utils.lsp").if_support(method, bufnr)
	end

	if not is_lsp_attached(bufnr) then
		return
	end

	-- 幂等: 已处理过就跳过
	local ok_done = pcall(api.nvim_buf_get_var, bufnr, "telescope_lsp_takenover")
	if ok_done then
		return
	end

	local tb = require("telescope.builtin")

	-- 不做手动 :del 的原因：
	-- - 在同一 buffer 上, 后定义的本地映射会自然覆盖先定义者(包括 attach.lua)。
	-- - 直接 set buffer-local 映射即可达到接管目的, 更贴近“与原生 LSP 一致”的风格。
	-- - 若需要强制清理, 可在此处调用 keymap.del；但当前实现选择更简洁且足够稳妥的覆盖方式。

	-- 覆盖掉 lua/config/lsp/attach.lua 中的相关配置
	local keymaps = {

		["n|gi"] = map_callback(function()
				if if_support(vim.lsp.protocol.Methods.textDocument_implementation) then
					tb.lsp_implementations({
						reuse_win = true, -- jump to existing window if buffer is already open
					})
				end
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: (跳转到)实现"),

		["n|gd"] = map_callback(function()
				if if_support(vim.lsp.protocol.Methods.textDocument_definition) then
					tb.lsp_definitions({
						reuse_win = true,
					})
				end
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: (跳转到)定义"),

		["n|gt"] = map_callback(function()
				if if_support(vim.lsp.protocol.Methods.textDocument_typeDefinition) then
					tb.lsp_type_definitions({
						reuse_win = true,
					})
				end
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: (跳转到)类型定义"),

		["n|gr"] = map_callback(function()
				if if_support(vim.lsp.protocol.Methods.textDocument_references) then
					tb.lsp_references({
						reuse_win = true,
					})
				end
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: (查找)引用"),

		["n|<leader>o"] = map_callback(function()
				if if_support(vim.lsp.protocol.Methods.textDocument_documentSymbol) then
					tb.lsp_document_symbols({
						ignore_symbols = { "field", "variable" },
					})
				end
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: (查找)当前文件符号"),

		["n|<leader>O"] = map_callback(function()
				if if_support(vim.lsp.protocol.Methods.workspace_symbol) then
					tb.lsp_dynamic_workspace_symbols({})
				end
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: (查找)工作区符号"),

		-- vscode 行为兼容, 只能类似.
		["n|<c-t>"] = map_callback(function()
				if if_support(vim.lsp.protocol.Methods.workspace_symbol) then
					tb.lsp_workspace_symbols({
						query = vim.fn.expand("<cword>"),
						show_line = true,
					})
				end
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: 在工作区查找当前光标下的符号"),

		["n|<leader>dl"] = map_callback(function()
				tb.diagnostics({
					bufnr = 0,
				})
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: (打开)当前文件的诊断列表"),

		["n|<leader>dL"] = map_callback(function()
				tb.diagnostics({
					bufnr = nil,
				})
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: (打开)工作区诊断列表"),

		["n|<leader>lca"] = map_callback(function()
				if if_support(vim.lsp.protocol.Methods.textDocument_codeAction) then
					tb.lsp_code_actions()
				end
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: Code Action"),

		["n|<leader>lci"] = map_callback(function()
				if client and client.server_capabilities and client.server_capabilities.callHierarchyProvider then
					tb.lsp_incoming_calls()
				end
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: (查找)被谁调用"),

		["n|<leader>lco"] = map_callback(function()
				if client and client.server_capabilities and client.server_capabilities.callHierarchyProvider then
					tb.lsp_outgoing_calls()
				end
			end)
			:with_buffer(bufnr)
			:with_noremap()
			:with_silent()
			:with_desc("LSP: (查找)我调用谁"),
	}

	bind.nvim_load_mapping(keymaps)

	-- 标记为已处理
	pcall(api.nvim_buf_set_var, bufnr, "telescope_lsp_takenover", true)
end

return M
