# session

意图: 会话/工作区持久化。

原路径映射:

- /Users/jensen/.config/nvim/lua/plugins/ide/persistence.lua

---

- lastplace: 记忆文件上次光标位置。
    - 触发: `event = {"BufReadPre"}`
    - 仓库: <https://github.com/ethanholz/nvim-lastplace>
    - 配置: `lua/plugins/ui/lastplace.lua`

- bufferline: 标签/缓冲区栏, 支持诊断与图标。
    - 触发: `event = "VeryLazy"`
    - 备注: 使用 `mode = "tabs"` 模拟 tabline；诊断来源 `nvim_lsp`
    - 仓库: <https://github.com/akinsho/bufferline.nvim>
    - 配置: `lua/plugins/ui/bufferline.lua`

## 大纲

- 概览与动机
- 安装与接入
- 现有配置与键位(结合 `lua/plugins/session/persistence.lua` 行号)
- 使用与交互
- 状态管理与权衡
- 故障排查
- 可视化

---

## 概览与动机

- 目标: 在重开 Neovim 或切换到同一目录/项目时, 快速恢复上次的窗口布局、缓冲区集合、编辑上下文。
- 为什么用会话: 相比手动 `:mksession`, 使用插件统一保存/加载策略, 降低路径与选项管理的心智负担。
- 设计取向: 最小化配置。当前仅提供必要的键位, 将保存/目录等细节交由插件默认策略处理。

---

## 安装与接入

- 仓库: `folke/persistence.nvim`
- 配置文件: `lua/plugins/session/persistence.lua`
- 在 `lua/core/lazy.lua:L77` 通过 `{ import = "plugins.session" }` 自动导入该模块, 无需显式 require。

---

## 现有配置与键位(结合行号)

- 键位定义入口: `lua/plugins/session/persistence.lua`
    - 恢复当前目录会话: `L7-L12` 调用 `require("persistence").load()` 绑定到 `n|<leader>pc`
    - 恢复上一次会话: `L14-L21` 调用 `require("persistence").load({ last = true })` 绑定到 `n|<leader>pl`
    - 本次不保存会话: `L23-L29` 调用 `require("persistence").stop()` 绑定到 `n|<leader>px`
    - 应用键位: `L31` 通过 `bind.nvim_load_mapping(keymaps)` 生效
    - 插件规格: `L33-L37` 声明 `{ "folke/persistence.nvim", config = true }` 采用插件默认 setup

---

## 使用与交互

- 恢复当前目录会话: 按 `<leader>pc`
    - 行为: 加载与当前工作目录匹配的会话(若存在)。
- 恢复上一次会话: 按 `<leader>pl`
    - 行为: 忽略当前目录, 直接加载最近一次保存的会话(若存在)。
- 本次不保存会话: 按 `<leader>px`
    - 行为: 标记当前 Neovim 退出时不进行会话保存。

提示:

- 键位前缀 `<leader>` 请以你当前 `mapleader` 为准。
- 若目录下无已保存会话, 恢复操作不会生效(插件保持静默)。

---

## 状态管理与权衡

- 状态位置: 会话数据由插件持久化到其默认目录(本配置未覆盖路径), 本地磁盘是单一真实源。
- 生命周期: 保存发生在退出或插件触发的时机; 加载发生在显式调用 `load()/load{last=true}` 时。
- 共享范围: 会话按目录或“最近一次”语义区分, 彼此互不干扰。
- 设计权衡:
    - 极简配置降低维护成本, 但细粒度自定义(如保存选项/目录命名/分支隔离)依赖后续扩展。
    - 以“手动加载”为主, 避免自动接管导致的惊扰式行为。

---

## 故障排查

- 键位无效
    - 检查 `lua/core/lazy.lua:L77` 是否包含 `{ import = "plugins.session" }`。
    - 执行 `:map <leader>pc`/`:map <leader>pl`/`:map <leader>px` 确认映射是否存在。
- 未能恢复
    - 目标目录尚无会话文件时, `load()` 将无事发生; 先进行一次正常退出以触发保存。
- 与其他会话方案冲突
    - 若你同时启用了其他自动会话插件, 请避免双重保存/加载, 以免状态覆盖。

---

## 可视化

调用流程:

```mermaid
flowchart LR
  U[按键 <leader>pc/<leader>pl/<leader>px] --> M[utils.bind 映射]
  M --> P[persistence.lua]
  P -->|L7-L12| LoadCur[require("persistence").load()]
  P -->|L14-L21| LoadLast[require("persistence").load{ last: true }]
  P -->|L23-L29| Stop[require("persistence").stop()]
  P -->|L31| ApplyMap[bind.nvim_load_mapping]
  ApplyMap --> Done[映射可用]
```

关键函数调用路径:

```
lua/plugins/session/persistence.lua
├─ L7-L12: <leader>pc -> require("persistence").load()
├─ L14-L21: <leader>pl -> require("persistence").load{ last = true }
├─ L23-L29: <leader>px -> require("persistence").stop()
├─ L31: 应用映射 bind.nvim_load_mapping(keymaps)
└─ L33-L37: 返回插件规格 { "folke/persistence.nvim", config = true }

lua/core/lazy.lua
└─ L77: { import = "plugins.session" }
