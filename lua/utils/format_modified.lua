-- Format only modified hunks using LSP range formatting.
-- If no hunks or no range-format support, fallback to full formatting via conform/guard/LSP.

local M = {}

-- Detect git repo root for a given path
local function repo_root(path)
	local dir = vim.fn.fnamemodify(path, ":h")
	local found = vim.fs.find(".git", { upward = true, path = dir })[1]
	if not found then
		return nil
	end
	return vim.fn.fnamemodify(found, ":h")
end

-- Run git diff -U0 to get changed line ranges in the working tree
local function changed_ranges(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(bufnr)
	if filename == "" then
		return {}
	end
	local root = repo_root(filename)
	if not root or vim.fn.executable("git") ~= 1 then
		return {}
	end
	-- Make path relative to repo root to avoid quoting issues
	local rel = filename:sub(#root + 2)
	local cmd = { "git", "-C", root, "diff", "-U0", "--", rel }
	local out = vim.system(cmd, { text = true }):wait()
	if out.code ~= 0 then
		return {}
	end
	local ranges = {}
	for line in (out.stdout or ""):gmatch("[^\n]+") do
		-- @@ -a,b +c,d @@
		local c, d = line:match("@@%s%-[%d,]+%s%+(%d+),?(%d*)%s@@")
		if c then
			c = tonumber(c)
			d = tonumber(d) or 1
			if d > 0 then
				table.insert(ranges, { start_line = c, end_line = c + d - 1 })
			end
		end
	end
	return ranges
end

local function have_range_formatter(bufnr)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		if client.server_capabilities and client.server_capabilities.documentRangeFormattingProvider then
			return true
		end
	end
	return false
end

local function lsp_format_ranges(bufnr, ranges)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	for _, r in ipairs(ranges) do
		local s = { line = r.start_line - 1, character = 0 }
		local e = { line = r.end_line - 1, character = 2 ^ 31 - 1 }
		vim.lsp.buf.format({
			bufnr = bufnr,
			async = false,
			range = { start = s, ["end"] = e },
		})
	end
end

-- Public API
-- opts = { fallback = "guard" | "conform" | "lsp" }
function M.format_modified(opts)
	opts = opts or {}
	local bufnr = vim.api.nvim_get_current_buf()
	local ranges = changed_ranges(bufnr)
	if #ranges > 0 and have_range_formatter(bufnr) then
		lsp_format_ranges(bufnr, ranges)
		return
	end
	-- fallback
	local fb = opts.fallback or "lsp"
	if fb == "guard" then
		if vim.fn.exists(":Guard") == 2 then
			vim.cmd("Guard fmt")
		else
			vim.lsp.buf.format({ async = true })
		end
	elseif fb == "conform" then
		local ok, conform = pcall(require, "conform")
		if ok then
			conform.format({ async = true })
		else
			vim.lsp.buf.format({ async = true })
		end
	else
		vim.lsp.buf.format({ async = true })
	end
end

return M
