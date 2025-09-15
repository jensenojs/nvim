# Lang 插件模块

意图: 语言生态相关插件（与LSP解耦的语言专属插件/增强）。

## 插件列表

### rust.lua
- 插件: `mrcjkb/rustaceanvim`
- 仓库: https://github.com/mrcjkb/rustaceanvim
- 功能: Rust语言生态集成
- 配置特点:
  - 提供Rust LSP(rust-analyzer)与生态整合
  - 集成DAP调试支持
  - 提供运行和调试目标的便捷入口

### markdown.lua
- 插件: `MeanderingProgrammer/render-markdown.nvim`
- 仓库: https://github.com/MeanderingProgrammer/render-markdown.nvim
- 功能: Markdown渲染和预览增强
- 配置特点:
  - 语法高亮增强
  - 标题美化
  - 代码块渲染

## 使用说明

### Rust 集成使用说明

#### 能力速览
- 提供 Rust LSP(rust-analyzer) 与生态整合
- 集成 DAP：优先使用 `codelldb` 作为适配器(自动探测或手动指定)
- 暴露命令/接口用于直接运行或调试"当前工程/光标附近"的目标(适合单元测试/集成测试)

#### 调试单个测试的常用入口
- 使用命令(或映射)触发 Rust 工具的"可运行/可调试目标"列表：
    - `:RustLsp runnables` → 运行目标(cargo run/test 等)
    - `:RustLsp debuggables` → 调试目标(含具体单测)
- 选中后会自动生成并启动对应的 `codelldb` 会话
- 首次进入工程或切换分支后, 需等待 rust-analyzer/cargo 初始化元数据；列表延迟数秒属正常现象

#### DAP 适配器
- 若系统可直接找到 `codelldb`, 插件会自动配置
- 若需手动指定, 可在全局变量中提供路径(来自上游文档范式)：

```lua
vim.g.rustaceanvim = function()
  local cfg = require('rustaceanvim.config')
  local codelldb_path = '/path/to/codelldb'      -- 例如: mason 安装目录或 VSCode 扩展目录
  local liblldb_path  = '/path/to/liblldb.dylib' -- Linux 为 .so, Windows 为 .dll
  return { dap = { adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path), }, }
end
```

#### 与现有 dap 工作流的关系
- 你可以继续用 `F5`/`F10`/`F11`/`F12` 与 `dap-ui` 控制会话
- 想"精准调试单个测试"时, 优先用 `:RustLsp debuggables` 在列表里选到具体测试目标再进入调试

#### 诊断与常见现象
- 列表首次为空或只出现少量项：通常是 rust-analyzer 仍在解析工程；稍候再试或触发一次 `:RustLsp debuggables` 重新拉取
- `codelldb` 未找到：确保通过包管理器或 mason 安装, 并确认二进制/库路径可被检测到

### Markdown 集成使用说明

#### 功能特性
- 增强的Markdown渲染效果
- 代码块语法高亮
- 标题美化和编号
- 列表和表格渲染优化
- 链接和图片预览

#### 配置说明
插件使用以下配置：
```lua
opts = function()
  overrides = {
    -- Markdown Header Background Overrides with Foreground Colors
    ["@markup.heading.1.markdown"] = { fg = "#fb4934", bg = "", bold = true },
    ["@markup.heading.2.markdown"] = { fg = "#fabd2f", bg = "", bold = true },
    ["@markup.heading.3.markdown"] = { fg = "#b8bb26", bg = "", bold = true },
    ["@markup.heading.4.markdown"] = { fg = "#8ec07c", bg = "", bold = true },
    ["@markup.heading.5.markdown"] = { fg = "#83a598", bg = "", bold = true },
    ["@markup.heading.6.markdown"] = { fg = "#d3869b", bg = "", bold = true },
    ["DiffAdd"] = { fg = "", bg = "" },
  }
  backgrounds = {
    "RenderMarkdownH1Bg",
    "RenderMarkdownH2Bg",
    "RenderMarkdownH3Bg",
    "RenderMarkdownH4Bg",
    "RenderMarkdownH5Bg",
    "RenderMarkdownH6Bg",
  }
  require("render-markdown").setup({
    enabled = true,
  })
end,
```

#### 使用方法
- 插件会自动在打开Markdown文件时启用
- 提供命令 `:RenderMarkdown` 切换渲染状态
- 渲染效果包括：
  - 标题颜色和背景美化
  - 代码块语法高亮
  - 表格和列表优化显示
  - 链接和图片友好显示

#### 快捷键
- `<leader><leader>m`: 切换Markdown预览（如果配置了快捷键）

#### 与其它插件的关系
- 与Treesitter集成提供语法高亮
- 与nvim-web-devicons集成提供图标支持
- 可以与其它Markdown相关插件共存

### Go 语言支持（说明）

虽然当前目录中没有Go相关的配置文件，但可以通过添加以下配置来支持Go语言开发：

```lua
-- go.lua
return {
  "ray-x/go.nvim",
  dependencies = {
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("go").setup()
  end,
  event = {"CmdlineEnter"},
  ft = {"go", 'gomod'},
  build = ':lua require("go.install").update_all_sync()'
}
```

这将提供：
- Go LSP配置增强
- 调试支持
- 代码格式化和导入管理
- 测试运行和调试
- Go模组支持

### 其它语言扩展建议

可以根据需要添加其它语言的专用插件：
1. JavaScript/TypeScript: `nvim-lspconfig` 已经提供了良好的支持
2. Python: 可以集成 `python.nvim` 提供更多功能
3. Java: 可以使用 `nvim-jdtls` 插件
4. C/C++: 可以使用 `clangd` 作为LSP服务器