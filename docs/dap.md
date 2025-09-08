# Neovim DAP 基础概念与速览

本篇聚焦「必要概念」, 帮助你在 Neovim 中正确理解并使用 nvim-dap 调试栈。建议先通读, 再根据语言到对应的配置文档实践。

- 适用对象：已经会用 Neovim/Lazy.nvim 管理插件, 准备为项目加入调试能力的用户
- 相关目录：`lua/plugins/diagnostics/`(插件与 UI)、`lua/config/debug/`(语言配置)、`lua/utils/`(通用工具)
- 参考文档：
    - nvim-dap README: <https://github.com/mfussenegger/nvim-dap>
    - Debug Adapter Installation Wiki: <https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation>
    - `:help dap.txt` / `:help dap-adapter` / `:help dap-configuration` / `:help dap-listeners`

---

## 1. 为什么是 DAP？

DAP(Debug Adapter Protocol)将「编辑器」与「调试器」解耦：

- 编辑器(nvim-dap)实现通用的客户端协议
- 各语言生态提供「适配器」(Adapter), 将协议转译为具体调试器的调用(如 delve/debugpy/codelldb 等)

因此, 在 Neovim 中调试任何语言, 本质上是：安装一个适配器 + 提供若干调试“场景”配置。

---

## 2. 三个核心对象

nvim-dap 的核心是三组表：

- `dap.adapters[<adapter_name>]`
    - 定义「如何启动/连接」调试器进程
    - 例如：delve、debugpy、codelldb、pwa-node、coreclr ...

- `dap.configurations[<filetype>] = { ... }`
    - 为某个 `&filetype` 提供一组调试“场景”(Launch/Attach/Test/Module 等)
    - 每个场景的 `type` 字段必须指向一个已存在的 `dap.adapters[<type>]`

- UI/扩展组件
    - `nvim-dap-ui`、`nvim-dap-virtual-text`、REPL 高亮等
    - 负责可视化变量/栈帧/断点、内联变量值、REPL 体验等

> 记忆法：Configurations 决定“调什么 + 怎么调”, Adapters 决定“用哪个调试器 + 怎么启动它”。

---

## 3. 匹配与运行流程(必懂)

当你在某文件(如 `main.go`)启动调试：

1) Neovim 的 `&filetype` 为 `go`
2) nvim-dap 查询 `dap.configurations.go` 列表, 供你选择调试场景
3) 选中某条配置后, 取其 `type`(如 `go`)
4) 用这个 `type` 去匹配 `dap.adapters["go"]`
5) 启动该 Adapter(以 `executable`/`server` 模式)、传入该配置的参数, 开启会话

因此, 务必确保：

- `configurations[*].type` 与 `adapters[<type>]` 的 key 完全一致
- `configurations` 的索引(左值)通常为 `&filetype`

---

## 4. Adapter 两种形态

- `type = "executable"`
    - 直接以命令行方式启动调试器进程
    - 典型：`debugpy`(`python -m debugpy.adapter`)

- `type = "server"` + `port = "${port}"`
    - 启动一个本地 server(端口动态 `${port}`), nvim-dap 以 TCP 连接
    - 典型：`codelldb`、`dlv dap`(Go 推荐)
    - 动态端口能避免固定端口被占用

---

## 5. Configuration 常用字段速查

- `type`: 字符串。必须与某个 `dap.adapters[...]` 的 key 完全一致
- `request`: `"launch"` | `"attach"`
- `name`: 该场景在选择器中的显示名
- `program`: 可执行文件/脚本路径；可为函数延迟求值
- `module`: Python 等语言可使用模块名启动(`python -m <module>`)
- `cwd`: 工作目录；常用 `${workspaceFolder}` 或 `./${relativeFileDirname}`
- `args`: 传给被调试程序的参数
- `env`/`envFile`: 进程环境变量
- `stopOnEntry`: 启动后是否在入口即停
- `processId`: `attach` 模式下选择/指定进程(可用 `require('dap.utils').pick_process`)

建议：凡是需要用户输入/依赖上下文的字段, 使用函数延迟求值, 避免在 Neovim 启动时弹输入框。

---

## 6. 会话生命周期与 UI

- 典型事件点
    - `dap.listeners.after.event_initialized[...]`: 会话建立后(可打开 UI / 绑定会话期按键)
    - `dap.listeners.before.event_terminated[...]`: 会话终止前(关闭 UI / 清理按键)
    - `dap.listeners.before.event_exited[...]`: 调试器退出前(同上)

- UI 推荐
    - `rcarriga/nvim-dap-ui`: 侧边栏显示变量/堆栈/断点/REPL 控制
    - `theHamsta/nvim-dap-virtual-text`: 悬停行内显示变量值
    - REPL 打开：`require('dap').repl.open()`

- 键位习惯(可按需变更)
    - F5 继续、F9 断点、F10 单步越过、F11 单步进入、F12 单步跳出
    - 建议只在会话期间生效的“临时按键”, 并在会话结束时清理

> 最佳实践：将 UI 相关的打开/关闭与按键注册集中在一个地方维护(例如 `lua/plugins/diagnostics/dap-ui.lua`)。

---

## 7. 安装策略(重要理念)

nvim-dap 的“非目标”(Non-Goals)之一是：不负责安装调试器。建议：

- 使用系统包管理器 / Nix / Ansible / Mason 等方案安装调试器
- 若已使用 `mason.nvim`, 可通过 `mason-nvim-dap.nvim` 统一管理调试器(自动安装/路径补全)
- 确保 `PATH`/虚拟环境(如 Python venv)正确；否则 `vim.fn.exepath()`/`python -m ...` 可能失败

> 你可以先本地跑通, 再视情况引入 `mason-nvim-dap.nvim` 降低环境差异。

---

## 8. 语言扩展优先

一些语言有维护良好的 nvim 扩展, 优先使用可降低维护成本：

- Go: `leoluz/nvim-dap-go`
- Python: `mfussenegger/nvim-dap-python`
- JS/TS/浏览器: `microsoft/vscode-js-debug`(可配合 `nvim-dap-vscode-js`)
- Lua(Neovim 自身): `one-small-step-for-vimkind`(osv)
- .NET: `netcoredbg`

仅在扩展无法满足时, 再回落到手动配置 adapter + configurations。

---

## 9. 常见陷阱与排查

- 适配器 key 与配置 `type` 不一致
    - 现象：启动时提示未找到 adapter 或无反应
    - 解决：确保 `dap.adapters["<type>"]` 与配置里的 `type = "<type>"` 完全一致

- 固定端口引发冲突
    - 现象：已经有进程占用该端口, 导致连接失败
    - 解决：优先使用 `server + port = "${port}"` 的动态端口写法

- UI 生命周期重复
    - 现象：UI 被重复打开/关闭, 或事件被注册多次
    - 解决：集中在一个模块管理 listeners, 避免多处注册

- 过早求值导致启动时弹窗
    - 现象：Neovim 启动即出现 `vim.fn.input` 提示
    - 解决：将需要交互/上下文的信息包裹在「函数」里(延迟到会话启动时求值)

- 可执行/解释器查找失败
    - 现象：`vim.fn.exepath()` 返回空、`python -m debugpy` 失败
    - 解决：检查 PATH/虚拟环境, 或使用 Mason 安装并确保可寻址到具体二进制

---

## 10. 最小工作流速记

1) 在代码中设置断点(`<F9>` 或 `:DapToggleBreakpoint`)
2) 选择一个调试场景(`<F5>` 或 `:DapContinue`)
3) 会话中使用单步/查看变量/打开 REPL(`<F10>/<F11>/<F12>`、`<F7>` 打开/关闭 UI)
4) 终止/退出(`:DapTerminate`/`:DapDisconnect`)

---

## 11. 目录与职责建议(与本配置约定相符)

- `lua/plugins/diagnostics/`
    - `dap.lua`：核心插件与基础键位、与 mason(可选)的集成
    - `dap-ui.lua`：UI 布局、会话生命周期、临时键位
    - `dap-virtual-text.lua` / `dap-repl-highlights.lua`：辅助 UI

- `lua/config/debug/`
    - `init.lua`：只做语言表驱动注册(adapters + configurations), 不负责 UI
    - `*.lua`：各语言的 adapter 与 configurations, 注意 `type` 与 adapter key 一致

- `lua/utils/`
    - `dap.lua`：输入参数/路径/环境等工具函数(建议延迟求值)

---

## 12. 进一步阅读与链接

- nvim-dap README 与 Help：`:help dap.txt`、`:help dap-adapter`、`:help dap-configuration`、`:help dap-api`
- Debug Adapter Installation(社区维护)：<https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation>
- Adapters 实现列表(DAP 官方)：<https://microsoft.github.io/debug-adapter-protocol/implementors/adapters/>

> 建议先在一个最小示例仓库中验证 Launch/Attach 基本流程, 再将可复用的配置抽到 `lua/config/debug/` 中。这样能快速定位问题, 且便于后续扩展更多语言。
