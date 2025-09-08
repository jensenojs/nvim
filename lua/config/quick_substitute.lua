local M = {}

M.state = {
  -- stylua: ignore start
  defaults = {
    scope = "line",            -- 非可视模式下的默认作用域: line|buffer
    word_boundary = false,     -- 是否仅整词匹配: 用 \< 和 \> 包裹模式
    flags = "g",               -- :s 标志位, 例如: g(全局)/c(确认)/i(忽略大小写)
    smartcase = true,          -- 若启用: 根据 ignorecase/smartcase 选项推断大小写行为
    keep_selection = true,     -- 可视模式执行后是否用 :normal! gv 恢复上次选区
    nohlsearch = false,        -- 执行后是否 :noh 清理高亮
    preview = true,            -- 执行前是否预览最终命令
  -- stylua: ignore end
    delimiters = { "/", "#", "@", "|", "%", "~", "+", "=", ":", ",", ";" }, -- 候选分隔符
  },
}

local DEFAULT_KEYS = {
	visual = "<leader>ss",
	line = "<leader>ss",
	buffer = "<leader>sS",
}

local function in_visual_mode()
	local m = vim.fn.mode()
	return m == "v" or m == "V" or m == "\022"
end

local function get_visual_range()
	local start = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")
	local srow = start[2] - 1
	local scol = start[3] - 1
	local erow = end_pos[2] - 1
	local ecol = end_pos[3] - 1
	if srow > erow or (srow == erow and scol > ecol) then
		srow, erow, scol, ecol = erow, srow, ecol, scol
	end
	return { srow, scol, erow, ecol }
end

-- 小工具: 选择分隔符. 从 candidates 中挑选一个不出现在 old/new 中的字符; 否则询问用户
local function choose_delimiter(oldword, newword, candidates)
	for _, d in ipairs(candidates) do
		if not string.find(oldword or "", d, 1, true) and not string.find(newword or "", d, 1, true) then
			return d
		end
	end
	local input = vim.fn.input("分隔符不可用, 请输入一个不含于两端字符串的单字符: ")
	if type(input) == "string" and #input >= 1 then
		return string.sub(input, 1, 1)
	end
	return "/"
end

local function resolve_flags(flags, smartcase)
	local f = flags or ""
	if smartcase then
	end
	return f
end

-- 小工具: 构造 :s 的范围字符串
local function build_range(has_visual, scope)
	if has_visual then
		return "'<,'>" -- 对应上次可视选区
	end
	if scope == "line" then
		return ".,." -- 显式限定当前行
	elseif scope == "buffer" then
		return "%" -- 整个缓冲区
	else
		-- 未知 scope 时退回当前行
		return ".,."
	end
end

-- 小工具: 构造 \V + 整词边界的模式串, 并对分隔符与反斜杠做转义
local function build_pattern(oldword, delimiter, word_boundary)
	-- 在 \V very nomagic 下, 仅 \\ 保持转义意义; 其他大多字符以字面含义匹配
	local pat = vim.fn.escape(oldword, "\\" .. delimiter)
	if word_boundary then
		-- 注意: 在 \V 语境下, \\< 和 \\> 仍具备“单词边界”的特殊意义
		pat = "\\<" .. pat .. "\\>"
	end
	-- 前置 \V 降低魔法风险
	return "\\V" .. pat
end

-- 小工具: 构造替换串, 需要转义 & 与 \\ 以及分隔符本身
local function build_replacement(newword, delimiter)
	return vim.fn.escape(newword, "\\" .. delimiter .. "&")
end

-- 小工具: 统一的交互输入. 目前用 vim.fn.input 实现同步流程; 后续可替换为 vim.ui.input
local function prompt(label)
	local prompt_text = label .. ": "
	local v = vim.fn.input(prompt_text)
	if v == nil or v == "" then
		return nil
	end
	return v
end

function M.setup(opts)
	if type(opts) == "table" then
		for k, v in pairs(opts) do
			M.state.defaults[k] = v
		end
	end

	local provided_keys = opts and opts.keys
	if provided_keys ~= false then
		local keys = provided_keys or DEFAULT_KEYS
		if keys then
			if keys.visual then
				vim.keymap.set({ "v", "x" }, keys.visual, function()
					M.run({})
				end, { desc = "快速替换: 作用于可视选区" })
			end
			if keys.line then
				vim.keymap.set("n", keys.line, function()
					M.run({ scope = "line" })
				end, { desc = "快速替换: 当前行" })
			end
			if keys.buffer then
				vim.keymap.set("n", keys.buffer, function()
					M.run({ scope = "buffer" })
				end, { desc = "快速替换: 整个缓冲区" })
			end
		end
	end
end

function M.run(opts)
	opts = opts or {}
	local cfg = M.state.defaults

	-- 计算最终配置(浅合并)
	local scope = opts.scope or cfg.scope
	local word_boundary = opts.word_boundary or cfg.word_boundary
	local flags = resolve_flags(opts.flags or cfg.flags, opts.smartcase or cfg.smartcase)
	local keep_selection = opts.keep_selection or cfg.keep_selection
	local nohlsearch = opts.nohlsearch or cfg.nohlsearch
	local preview = opts.preview or cfg.preview
	local delimiters = cfg.delimiters

	local has_visual = in_visual_mode()
	local buf = 0 -- 当前 buffer

	local srow, scol, erow, ecol
	if has_visual then
		local range = get_visual_range()
		if range then
			srow, scol, erow, ecol = unpack(range)
			-- 设置 marks 以支持 '<,'> 范围
			vim.api.nvim_buf_set_mark(0, "<", srow + 1, scol, {})
			vim.api.nvim_buf_set_mark(0, ">", erow + 1, ecol, {})
		else
			has_visual = false
		end
	end

	-- 交互获取 old/new
	local oldword
	local newword
	local ok, err = pcall(function()
		oldword = prompt("要替换的旧字符串")
		newword = prompt("替换成的新字符串")
	end)
	if not ok then
		vim.notify("交互输入中断", vim.log.levels.INFO, { title = "quick_substitute" })
		return
	end
	if oldword == nil or oldword == "" then
		vim.notify("未提供旧字符串, 已取消", vim.log.levels.INFO, { title = "quick_substitute" })
		return
	end

	-- 选择分隔符并构造模式/替换串
	local delimiter = choose_delimiter(oldword, newword, delimiters)
	local pattern = build_pattern(oldword, delimiter, word_boundary)
	local replacement = build_replacement(newword, delimiter)

	-- 构造范围
	local range = build_range(has_visual, scope)

	-- 预览执行命令(仅展示, 便于用户理解): 注意不要泄漏过长字符串
	local preview_cmd =
		string.format("%ss%s%s%s%s%s", range, delimiter, pattern, delimiter, replacement, delimiter .. flags)
	if preview then
		vim.notify("即将执行: :" .. preview_cmd, vim.log.levels.INFO, { title = "quick_substitute" })
	end

	-- 执行替换
	vim.cmd(preview_cmd)

	-- 可选恢复可视选区
	if has_visual and keep_selection then
		-- gv: 重新选择上一次可视选区, 比单纯 :normal! v 更准确
		vim.cmd("normal! gv")
	end

	if nohlsearch then
		vim.cmd("noh")
	end
end

return M
