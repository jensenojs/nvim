-- https://github.com/mfussenegger/nvim-dap-python
-- 由 nvim-dap-python 接管 Python 的调试适配器与配置
return {
	"mfussenegger/nvim-dap-python",
	ft = { "python" },
	dependencies = { "mfussenegger/nvim-dap" },
	opts = {},
	config = function(_, _)
		local function is_windows()
			local sysname = vim.loop.os_uname().sysname
			return sysname == "Windows_NT"
		end

		local function file_exists(path)
			return path and vim.fn.filereadable(path) == 1
		end

		local function join_path(dir, ...)
			local sep = is_windows() and "\\" or "/"
			local full = dir or ""
			for _, part in ipairs({ ... }) do
				if not part or part == "" then
					goto continue
				end
				if #full > 0 and not full:match(sep .. "$") then
					full = full .. sep .. part
				else
					full = full .. part
				end
				::continue::
			end
			return full
		end

		local function python_from_venv_dir(venv_dir)
			if not venv_dir or venv_dir == "" then
				return nil
			end
			if is_windows() then
				local p = join_path(venv_dir, "Scripts", "python.exe")
				if file_exists(p) then
					return p
				end
			else
				local p = join_path(venv_dir, "bin", "python")
				if file_exists(p) then
					return p
				end
			end
			return nil
		end

		local function find_project_root()
			local bufname = vim.api.nvim_buf_get_name(0)
			local start = (bufname ~= "") and bufname or vim.loop.cwd()
			local root_markers = { "pyproject.toml", "setup.cfg", "setup.py", "requirements.txt", ".git" }
			local found = vim.fs.find(root_markers, { path = start, upward = true })[1]
			return found and vim.fs.dirname(found) or vim.loop.cwd()
		end

		local function resolve_project_python()
			-- 1) 优先项目本地 venv (.venv/venv/env/.env), 涵盖 rye/uv 常见布局
			local root = find_project_root()
			for _, dirname in ipairs({ ".venv", "venv", "env", ".env" }) do
				local p = python_from_venv_dir(join_path(root, dirname))
				if p then
					return p
				end
			end

			-- 2) 其后才使用环境变量中的 venv
			for _, envkey in ipairs({ "VIRTUAL_ENV", "CONDA_PREFIX" }) do
				local envdir = vim.env[envkey]
				local p = python_from_venv_dir(envdir)
				if p then
					return p
				end
			end

			-- 3) 若安装了 uv, 则交给 uv 处理(支持 per-project venv 管理)
			if vim.fn.executable("uv") == 1 then
				return "uv"
			end

			-- 4) 常规回退
			if vim.fn.executable("python3") == 1 then
				return "python3"
			end
			return "python"
		end

		local dap_python = require("dap-python")
		-- 同步暴露自定义解析, 以便后续需要动态决策
		dap_python.resolve_python = resolve_project_python
		dap_python.setup(resolve_project_python())
	end,
}


