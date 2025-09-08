# lang

意图: 语言生态(与 lsp 解耦的语言专属插件/增强)。

原路径映射:

- <https://github.com/ray-x/go.nvim>
- /Users/jensen/.config/nvim/lua/plugins/ide/coding/rustaceanvim.lua
- /Users/jensen/.config/nvim/lua/plugins/ui/markdown.lua

---

## Rust

- 插件: `mrcjkb/rustaceanvim` (已在 `lua/plugins/lang/rust.lua` 声明)
- 参考: [rustaceanvim usage & features](https://github.com/mrcjkb/rustaceanvim#books-usage--features)

### 能力速览

- 提供 Rust LSP(rust-analyzer) 与生态整合。
- 集成 DAP：优先使用 `codelldb` 作为适配器(自动探测或手动指定)。
- 暴露命令/接口用于直接运行或调试“当前工程/光标附近”的目标(适合单元测试/集成测试)。

### 调试单个测试的常用入口

- 使用命令(或映射)触发 Rust 工具的“可运行/可调试目标”列表：
    - `:RustLsp runnables` → 运行目标(cargo run/test 等)
    - `:RustLsp debuggables` → 调试目标(含具体单测)
- 选中后会自动生成并启动对应的 `codelldb` 会话。
- 首次进入工程或切换分支后, 需等待 rust-analyzer/cargo 初始化元数据；列表延迟数秒属正常现象。

### DAP 适配器

- 若系统可直接找到 `codelldb`, 插件会自动配置。
- 若需手动指定, 可在全局变量中提供路径(来自上游文档范式)：

```lua
vim.g.rustaceanvim = function()
  local cfg = require('rustaceanvim.config')
  local codelldb_path = '/path/to/codelldb'      -- 例如: mason 安装目录或 VSCode 扩展目录
  local liblldb_path  = '/path/to/liblldb.dylib' -- Linux 为 .so, Windows 为 .dll
  return { dap = { adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path), }, }
end
```

### 与现有 dap 工作流的关系

- 你可以继续用 `F5`/`F10`/`F11`/`F12` 与 `dap-ui` 控制会话。
- 想“精准调试单个测试”时, 优先用 `:RustLsp debuggables` 在列表里选到具体测试目标再进入调试。

### 诊断与常见现象

- 列表首次为空或只出现少量项：通常是 rust-analyzer 仍在解析工程；稍候再试或触发一次 `:RustLsp debuggables` 重新拉取。
- `codelldb` 未找到：确保通过包管理器或 mason 安装, 并确认二进制/库路径可被检测到。
