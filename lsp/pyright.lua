-- lsp/pyright.lua
-- 来源文档: https://github.com/microsoft/pyright/blob/main/docs/configuration.md
--
-- Minimal, pragmatic defaults for pyright with comprehensive analysis settings
return {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		".git",
	},
	settings = {
		python = {
			analysis = {
				-- 自动搜索路径
				autoSearchPaths = true,
				-- 诊断模式: workspace(整个工作区) 或 openFilesOnly(仅打开的文件)
				diagnosticMode = "workspace",
				-- 使用库代码进行类型推断
				useLibraryCodeForTypes = true,
				-- 类型检查模式: off, basic, standard(默认), strict
				typeCheckingMode = "standard",

				-- 核心类型检查规则
				reportGeneralTypeIssues = true, -- 报告一般类型不一致问题
				reportPropertyTypeMismatch = true, -- 报告属性类型不匹配
				reportFunctionMemberAccess = true, -- 报告函数成员访问问题
				reportMissingImports = true, -- 报告缺失的导入
				reportInvalidTypeForm = true, -- 报告无效的类型表达式

				-- 类型注解和存根相关
				reportMissingTypeStubs = false, -- 报告缺失的类型存根文件
				reportImportCycles = false, -- 报告循环导入
				reportUnusedImport = "warning", -- 报告未使用的导入
				reportDuplicateImport = "warning", -- 报告重复导入

				-- 未使用代码检查
				reportUnusedClass = "warning", -- 报告未使用的类
				reportUnusedFunction = "warning", -- 报告未使用的函数
				reportUnusedVariable = "warning", -- 报告未使用的变量

				-- Optional类型检查
				reportOptionalSubscript = true, -- 报告Optional类型的下标操作
				reportOptionalMemberAccess = true, -- 报告Optional类型的成员访问
				reportOptionalCall = true, -- 报告Optional类型的调用
				reportOptionalIterable = true, -- 报告Optional类型的迭代
				reportOptionalContextManager = true, -- 报告Optional类型的上下文管理器使用
				reportOptionalOperand = true, -- 报告Optional类型的运算符操作

				-- 抽象类和协议检查
				reportAbstractUsage = true, -- 报告抽象类使用问题
				reportInconsistentOverload = true, -- 报告不一致的重载
				reportIncompatibleMethodOverride = true, -- 报告不兼容的方法覆盖

				-- 变量和声明检查
				reportUndefinedVariable = true, -- 报告未定义的变量
				reportUnboundVariable = true, -- 报告未绑定的变量
				reportRedeclaration = true, -- 报告重复声明

				-- 类型信息完整性检查
				reportUntypedFunctionDecorator = "warning", -- 报告无类型的函数装饰器
				reportUntypedClassDecorator = "warning", -- 报告无类型的类装饰器
				reportUntypedBaseClass = "warning", -- 报告无类型的基类
			},
		},
	},
}

