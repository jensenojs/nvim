# terminal

意图: 终端集成。

原路径映射:

- /Users/jensen/.config/nvim/lua/plugins/ide/terminal.lua

---

## 大纲

- 概览与动机
- 适用场景
- 安装与懒加载接入
- 关键配置项解读(结合 `lua/plugins/terminal/terminal.lua` 行号)
- 使用与交互
- 专用终端模式与扩展
- 状态管理与权衡
- 故障排查与健康检查
- 可视化

---

## 概览与动机

- 动机: 用一致按键在任意缓冲区快速出入终端, 避免手动管理窗口与模式切换的心智负担。
- 为什么不是原生终端: 原生需要手动分割/调整窗口、切换模式与缓冲区; toggleterm 提供统一 toggle、持久实例与窗口方向抽象。
- 设计取向: 少即是多。基于 lazy.nvim 的 `main + opts` 自动 setup, 使用 `keys` 回调进行专用终端的懒创建与模块级缓存, 与当前配置 `lua/plugins/terminal/terminal.lua` 一致。
- 官方定位: 轻量封装 Neovim Terminal API, 偏向“访问与管理”, 非全功能 REPL/任务系统。

---

## 适用场景

- 系统监控: 浮窗运行 `btop`, 通过 `<space>T` 快速开合, 不打断当前编辑上下文。
- 一次性命令/脚本: 执行后隐藏而不销毁实例, 再次 toggle 复用会话历史。
- 后台服务与日志: `tail -f`, `docker logs`, 进程启停; 可为常用命令定义专用终端并缓存。
- 数据库/CLI 工具: `mysql`/`psql`/`redis-cli` 等, 参考 btop 的专用实例模板化创建。
- 多会话工作流: 结合编号终端或自定义键位管理不同任务的终端实例。

---

## 安装与懒加载接入

- 插件: `akinsho/toggleterm.nvim` (Neovim ≥ 0.7)。
- 本仓库集成: `lua/plugins/terminal/terminal.lua` 采用 Lazy 的 `main + opts + keys` 风格懒加载。
    - 懒加载事件: `event = "VeryLazy"`
    - 自动 setup: 因为指定 `main = "toggleterm"` 且提供 `opts`, Lazy 会自动调用 `require("toggleterm").setup(opts)`。
    - 额外按键触发: `keys` 中的回调在首次触发时才按需 require 子模块并创建专用终端实例。

---

## 关键配置项解读

本仓库配置位置: `lua/plugins/terminal/terminal.lua`。

- open_mapping: `L33` 设置默认终端的切换映射为 `<C-\>`。
- start_in_insert: `L34` 打开终端即进入插入模式, 减少一次 `i` 操作。
- direction: `L35` 选择浮动终端, 获得“工具面板”体验。
- on_open: `L37-L44` 打开浮窗后强制进入插入、提供 `q` 关闭缓冲区的体验优化。
- 专用键位与懒创建: `L9-L29` `<space>T` 回调中按需 `require("toggleterm.terminal")`, 首次创建 `btop` 终端并缓存至模块级局部 `btop_term`(`L3`) 后复用。

---

## 使用与交互

- 默认终端切换: `<C-\>`(由 `open_mapping` 提供)。
- 打开 btop 浮动面板: `<space>T`。
- 多终端与前缀计数: 官方支持用计数前缀打开特定编号终端; 若需要, 可在 `open_mapping` 中使用数组或自行定义映射。
- 终端窗口导航: 可按需在终端模式下为 `<leader>h/j/k/l` 绑定 `wincmd` 实现窗口间移动(参见官方文档“Terminal window mappings”)。

---

## 专用终端模式与扩展

- btop 专用实例
    - 创建与切换逻辑在 `<space>T` 回调中实现, 代码位置 `lua/plugins/terminal/terminal.lua:L9-L29`。
    - 状态: 模块级局部变量 `btop_term`(`L3`) 作为缓存, 避免重复创建与资源浪费。

- 扩展示例: MySQL 模板
    - 参考 btop 实现, 在 `keys` 中新增回调, 首次触发时以 `Terminal:new{ cmd = "mysql ..." }` 创建并缓存, 后续复用。
    - 这样可以避免全局 `_mysql_toggle()`、更贴合“按需加载 + 局部状态”的范式。

---

## 状态管理与权衡

- 状态位置: 将 `Terminal` 实例缓存在模块级局部变量中(`btop_term`), 有效控制生命周期与可见范围。
- 生命周期: 首次按键才创建; 在 Neovim 进程内多次复用; 关闭面板并不销毁实例, 再按键可快速恢复。
- 共享范围: 该状态在当前配置模块作用域内共享; 不污染全局命名空间, 降低冲突与耦合。
- 设计权衡:
    - 集中化(单实例缓存)使复用与资源控制简单, 但若需要多 btop 会话则需扩展为实例池或编号映射。
    - 懒创建降低启动开销, 但首次触发会有一次 `require + new` 的冷启动延迟。

---

## 故障排查与健康检查

- 外部依赖: 请确保系统已安装 `btop`。本仓库在 `lua/utils/health.lua` 的 `checks` 中包含了 `"btop"` 的检测, 运行健康检查可快速定位缺失依赖。
- 键位未生效:
    - 确认 `core/lazy.lua` 中已启用 `{ import = "plugins.terminal" }`。
    - 确认未定义冲突映射; 可用 `:map <space>T` 检查。
- 浮动窗口行为异常:
    - 检查 `on_open`(`L37-L44`) 是否被外部 autocmd/插件覆盖。
    - 如需不同边框样式, 修改 `float_opts = { border = "double" }`。

---

## 可视化

调用路径示意:

```mermaid
flowchart LR
  K[<space>T 按键] -->|Lazy keys 触发| Load[加载插件模块]
  Load -->|opts 自动 setup| Setup[require("toggleterm").setup(opts)]
  K --> CB[回调执行]
  CB --> Req[pcall(require,"toggleterm.terminal")]
  Req -->|首次| New[Terminal:new{cmd:"btop",float}]
  Req -->|已存在| Use[btop_term]
  New --> Cache[缓存到 btop_term]
  Cache --> Tog[btop_term:toggle()]
  Use --> Tog
```

关键函数调用路径:

```
lua/plugins/terminal/terminal.lua
├─ L9-L29: <space>T 回调
│   ├─ require("toggleterm.terminal").Terminal
│   ├─ Terminal:new{ cmd = "btop", direction = "float" }
│   └─ :toggle()
└─ L32-L44: opts.setup (Lazy 自动调用)
    └─ on_open: startinsert! + 绑定 q 关闭
