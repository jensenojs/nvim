# Lua 精华与 Neovim 配置实践

- 读者与目标
    - 受众: 正在重构 Neovim 配置、需要以最小知识面掌握 Lua 的工程师
    - 目标: 用最少概念覆盖最大实践面, 强调状态边界、懒加载与幂等, 避免隐式副作用
    - 前置: 对 Neovim 的基础概念有直觉, Lua 语法略知一二

- 大纲
    - 核心理念: 状态管理的艺术与权衡
    - 模块与 require 缓存: 顶层副作用的陷阱
    - 作用域与命名空间: 全局污染的系统性代价
    - 幂等 setup(opts) 模式: 可重复调用的配置单元
    - 懒加载与执行时机: 把副作用放到正确的事件里
    - 错误隔离与版本兼容: pcall 与特性检测
    - 数据-能力-协作分层: 配置数据与逻辑能力解耦
    - 三类副作用的幂等写法: keymap/autocmd/user command
    - 调用路径示意与流程图
    - 附录: 自查清单与参考链接

---

## 核心理念

- 状态是系统复杂性的主要根源。必须明确状态的生命周期、共享范围与放置位置。
- 顶层副作用不可控。把状态变更延迟到“可观测事件”(event/ft/cmd/keys/cond)。
- 幂等是可靠性的前提。配置函数可重复调用而无重复注册、无资源泄露。

## 模块与 require 缓存

- 机制: `require()` 首次会执行模块顶层代码并缓存返回值；后续同名 `require()` 直接取缓存, 不再执行顶层。
- 反模式: 在模块顶层立即做副作用(设置键位、注册 autocmd、写全局变量)。这会让执行时机不可控且只执行一次, 难以调试与回滚。
- 建议: 导出表或函数, 把副作用放进导出函数, 在懒加载触发点再调用。

```lua
-- good: no side-effects at module top-level
local M = {}

function M.setup(opts)
  -- only compute or register when explicitly called
end

return M
```

## 作用域与命名空间

- 始终优先使用 `local`, 避免隐式全局。

```lua
-- bad
foo = 1  -- creates a global

-- good
local foo = 1
```

- Neovim 作用域表
    - `vim.g.*` 全局变量(尽量少用)
    - `vim.b.*` 缓冲区作用域
    - `vim.w.*` 窗口作用域
    - `vim.t.*` 标签页作用域
    - `vim.env.*` 环境变量

## 幂等 setup(opts) 模式

- 思路: 用 `opts` 描述配置数据, 函数内部合并默认项；所有注册行为前都先检查是否已存在。

```lua
local M = {}
local defaults = { enable = true }

local function merge_opts(user)
  return vim.tbl_deep_extend("force", defaults, user or {})
end

function M.setup(user_opts)
  local opts = merge_opts(user_opts)
  if not opts.enable then return end
  -- idempotent registrations here
  -- e.g. only set keymap if not already defined for this buffer
end

return M
```

- 关注点
    - 合并策略: `vim.tbl_deep_extend("force", ...)` 常用；对 list 类型是否追加或覆盖要有约定。
    - 资源重复: autocmd/group、augroup 名称、user command 名称需要唯一可复用。

## 懒加载与执行时机

- 触发器: 事件 `event`、文件类型 `ft`、命令 `cmd`、按键 `keys`、条件 `cond`。
- 实践建议
    - 补全引擎: `InsertEnter`
    - LSP: `BufReadPre`/`BufNewFile`
    - Treesitter: `BufReadPost`
    - Telescope: `cmd = { "Telescope" }` + 常用 `keys`
    - UI 组件: `VeryLazy` 或具体 `keys`
- 不在模块顶层 `require` 重型依赖, 把“重依赖 require”也推迟到 `setup()` 内。

## 错误隔离与版本兼容

- 可选依赖用 `pcall` 包裹, 失败则无声降级。
- API 变更做特性检测, 避免硬编码版本分支。

```lua
-- example: inlay hints compatibility
local ok, ih = pcall(function() return vim.lsp.inlay_hint end)
if ok then
  if type(ih) == "table" and ih.enable then
    pcall(ih.enable, true, { bufnr = bufnr })
  elseif type(ih) == "function" then
    pcall(ih, bufnr, true)
  end
end
```

## 数据-能力-协作分层

- 数据: 纯配置, 如 server 列表、ensure_installed、默认选项。
- 能力: 可被复用的逻辑, 如 `on_attach`、`capabilities`、`handlers`、格式化策略。
- 协作: 具体框架 glue, 如 mason-lspconfig 自动注册、treesitter 的 ensure_installed、cmp/blink 源组合。
- 收益: 配置可测、逻辑可复用、演进可控。

## 三类副作用的幂等写法

```lua
-- 1) keymap: give it a description and buffer-aware reuse
local function map(bufnr, mode, lhs, rhs, desc)
  local opts = { silent = true, noremap = true, desc = desc, buffer = bufnr }
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- 2) autocmd: use augroup and clear=true to avoid duplicates
local function autocmd(group, event, pattern, cb)
  local gid = vim.api.nvim_create_augroup(group, { clear = true })
  vim.api.nvim_create_autocmd(event, { group = gid, pattern = pattern, callback = cb })
end

-- 3) user command: redefine safely
local function usercmd(name, fn, opts)
  pcall(vim.api.nvim_del_user_command, name)
  vim.api.nvim_create_user_command(name, fn, opts or {})
end
```

## 调用路径示意

```text
init.lua
  └─ core/lazy.lua
       └─ lazy.setup(spec)
            ├─ plugins/... (懒加载: event/ft/cmd/keys/cond)
            └─ lsp/... (on_attach & capabilities)
```

## 流程图

```mermaid
flowchart TD
  A[Neovim start] --> B[init.lua]
  B --> C[core/lazy.lua]
  C --> D[lazy.setup(spec)]
  D --> E{defaults.lazy?}
  E -->|true| F[等待触发]
  E -->|false| G[直接加载]
  F --> H[event/ft/cmd/keys/cond]
  H --> I[加载插件]
  I --> J[opts 合并 -> setup]
  J --> K[config 收尾]
```

## 附录: 自查清单

- 顶层无副作用, 所有状态变更都在 `setup()` 或触发回调中
- `local` 优先, 禁止隐式全局
- `setup(opts)` 幂等, 重复调用无重复注册
- 重型 `require` 延迟到真正需要时
- 可选依赖 `pcall` 包裹, API 做特性检测
- 数据与能力解耦；协作逻辑最小化
- keymap/autocmd/user command 具名、可重复应用与撤销

## 参考链接

- lazy.nvim: <https://github.com/folke/lazy.nvim>
- 文档: <https://github.com/folke/lazy.nvim/blob/main/doc/lazy.nvim.txt>
- 讨论(触发器): <https://github.com/folke/lazy.nvim/discussions/1713>
- 讨论(opts vs config): <https://github.com/folke/lazy.nvim/discussions/1185>
