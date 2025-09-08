# Lua 高级语法与 Neovim DSL 实战

本篇聚焦“你正在使用、且后续重构必需”的 Lua 高阶主题, 以你当前配置中的 `bind` 链式 DSL 和 `keymap` 回退工具为主线, 讲清楚抽象与实现的权衡, 并提供可落地的范式与模板。

- 面向对象: 元表/原型、冒号语法、链式构建器
- 闭包与状态管理: 捕获、生命周期、性能
- 键位表达式与非破坏式回退: expr 与返回按键串
- require/模块缓存与命名空间: 可预热、幂等
- 弱表与缓存: memoize/registry 模式
- 协程与异步: 与 libuv 与 `vim.schedule()` 协作
- 错误处理与调试: pcall/xpcall/debug.traceback/health
- 统一的键位装载器适配: `vim.keymap.set` 与 DSL 互操作

---

## 阅读导航与结构大纲

- 概览
    - 本文以“设计哲学 → 代码范式 → 具体引用 → 取舍思考”的顺序展开。
- 可视化
    - 提供流程图与调用路径, 帮助定位 `bind.lua` 与 `keymap.lua` 的关键节点与风险点。
- 代码引用
    - 引用自: `lua/utils/bind.lua`、`lua/utils/keymap.lua`、`lua/plugins/ide/telescope.lua`、`lua/utils/health.lua`。

---

## 元表、原型与链式 DSL 的语义基础

- 大纲
    - 为什么 Lua 选择“原型而非类”
    - `__index`/`__newindex` 与查找路径
    - 冒号语法是如何传递 `self` 的
    - 链式构建器的“可变对象 + 返回 self”范式
    - 结合 `bind.lua` 精确引用与问题定位

### 原型机制与 `__index`

- 关键机制: `setmetatable(obj, Class); Class.__index = Class` 使得方法查找落到“类表”上。
- 冒号语法: `obj:method(x)` 等价于 `obj.method(obj, x)`, 自动把接收者作为第一个参数。

示例:

```lua
local Box = {}
Box.__index = Box

function Box:new()
  return setmetatable({ v = nil }, self)
end

function Box:set(v)
  self.v = v
  return self
end

function Box:done()
  return self.v
end
```

要点: 返回 `self` 支持 `Box:new():set(42):done()` 的链式风格。

### 在你当前 `bind.lua` 中的实现落点

- 构造与原型设置: `lhs_options:new()` 同构于“类表”, 引用见 `lua/utils/bind.lua:16-32`
    - 第29-31行: `setmetatable(instance, self); self.__index = self`
- 链式 setter: `:with_*()` 修改内部 `options` 并返回 `self`, 引用见 `lua/utils/bind.lua:72-108`
- 命令与回调二选一：
    - `:map_cr()` 将 `cmd` 组装成 `:%s<CR>`, 见 `lua/utils/bind.lua:41-46`
    - `:map_callback()` 将 `options.callback = fn`, 见 `lua/utils/bind.lua:63-69`

调用路径可视化:

```mermaid
flowchart LR
  A[plugins/ide/telescope.lua
  6-16 定义键位
  map_callback(...):with_*
  ] --> B[utils/bind.lua
  153-170 nvim_load_mapping]
  B --> C{buf?}
  C -- yes --> D[nvim_buf_set_keymap
  163]
  C -- no --> E[nvim_set_keymap
  165]
```

- 问题定位: `nvim_set_keymap` 与 `nvim_buf_set_keymap` 不支持 Lua 回调, `options.callback` 被丢弃, 见 `lua/utils/bind.lua:159-166`。
- 设计取舍: 前端 DSL 是健康的；后端装载器应统一改用 `vim.keymap.set`, 回调/desc/buffer 才能生效。

### 建议范式: “保持 DSL, 替换装载器”

- 解析 `"nv|<leader>x"` → 拆模式与 lhs 的逻辑保留。
- 将 `value.cmd` 与 `value.options.callback` 抽象为“函数或字符串”统一传给 `vim.keymap.set`。
- 如存在 `buffer`, 则注入 `opts.buffer = bufnr`。

调用路径对比:

```ascii
plugins/ide/telescope.lua
  -> bind.map_callback(...):with_*           (前端 DSL 不变)
  -> bind.load(...)                          (新装载器)
     -> vim.keymap.set(mode, lhs, rhs, opts) (回调、desc、buffer 生效)
```

---

## 闭包、捕获与状态管理

- 大纲
    - 闭包与上值: 何时有益、何时泄漏
    - `expr` 映射的闭包返回值范式
    - 非破坏式回退: 避免“读取即删除”
    - 结合 `keymap.lua` 的问题与替代方案

### 闭包的本质

- Lua 闭包捕获其创建时的词法环境上值, 常用于 DSL builder 的延迟执行与回退逻辑。
- 风险: 频繁创建闭包会增加短命对象分配；把大对象/模块闭包进上值易造成生命周期放大。

简例:

```lua
local function make_adder(n)
  return function(x)
    return x + n
  end
end

local add1 = make_adder(1)
local r = add1(41) -- 42
```

### 结合 `keymap.lua` 的回退设计

- 现状: `get_map()` 在读取时删除原映射, 见 `lua/utils/keymap.lua:24-45`；随后构造 `fallback` 闭包通过 `nvim_feedkeys` 回放, 见 `lua/utils/keymap.lua:72-95`。
- 风险: 破坏性读取使幂等与调试变得困难；且 `desc` 信息在读取→返回过程中丢失, 见 `lua/utils/keymap.lua:107-113`。

建议用“非破坏式回退”重写：让新映射在闭包中基于条件决定“接管或退回”, 通过 `expr = true` 返回按键串, 而不删除旧映射。

示范范式:

```lua
-- Non-destructive fallback using expr
vim.keymap.set("n", lhs, function()
  if should_takeover() then
    return "<cmd>Telescope find_files<cr>"
  else
    return lhs -- give original keys back to the mapping engine
  end
end, { expr = true, desc = "..." })
```

要点:

- 把“状态判断”放在执行期, 而不是“注册期删除旧状态”。
- 与“状态管理的艺术”一致: 状态的生命周期与位置直接影响系统能力边界。

---

## require/模块缓存与命名空间

- 大纲
    - `require` 的缓存语义与 `package.loaded`
    - 幂等 `setup()` 与惰性初始化
    - 避免顶层副作用与延迟重依赖 `require`
    - 命名空间与不泄漏全局

### require 缓存与重载

- 语义: 同一模块名首次 `require("mod")` 后会被放入 `package.loaded.mod`, 后续 `require` 直接返回相同表。
- 重载: 若确需热重载, 先 `package.loaded["mod"] = nil` 再 `require("mod")`。注意副作用与共享上值仍可能残留, 尽量在开发期使用, 生产配置避免。

### 幂等 setup 与惰性初始化

```lua
-- lua/my/mod.lua
local M = { _inited = false, opts = {} }

function M.setup(opts)
  if M._inited then return M end
  M.opts = vim.tbl_deep_extend("force", {
    -- defaults
  }, opts or {})
  M._inited = true
  return M
end

function M.do_something()
  -- Heavy requires inside runtime paths, not at module top
  local ok, telescope = pcall(require, "telescope.builtin")
  if ok then telescope.find_files() end
end

return M
```

要点:

- 顶层不做重副作用工作, 重依赖延迟到函数体内再 `pcall(require, ...)`。
- `setup()` 幂等, 重复调用不改变状态；适合与 lazy.nvim 的 `opts`/`config` 钩子配合。
- 参考你在 `0_lua_basics.md` 中对 lazy.nvim 触发器的梳理(如 `VeryLazy`、`cmd`、`keys`)。

### 命名空间与不污染全局

- 模块内全部用 `local` 绑定；通过 `return M` 暴露 API。
- 避免写入 `_G`/`vim.g` 作为状态容器, 除非特意作为跨模块协议。
- 需要跨缓冲区共享表时, 考虑使用“注册表 + 自动清理”(见下文“弱表与缓存”)。

---

## 弱表与 memoize 缓存

- 大纲
    - 弱键/弱值表与 GC 互动
    - memoize 模式与 Key 设计
    - 缓冲区注册表与自动清理

### 弱表基础

```lua
-- 弱键表: key 被 GC 时自动释放缓存
local REG = setmetatable({}, { __mode = "k" })
```

适用: 以 `bufnr`/`winid`/Lua 对象作为 key 的缓存, 不需要手动清理所有生命周期。

### 通用 memoize 模式

```lua
local function memoize(fn)
  local cache = {}
  return function(k)
    local v = cache[k]
    if v == nil then
      v = fn(k)
      cache[k] = v
    end
    return v
  end
end
```

注意:

- key 应该稳定且可比(string/number/table 引用本身)。
- 如以表做 key 且希望随 key 回收, 使用弱键表: `setmetatable(cache, { __mode = "k" })`。

### 每缓冲区注册表

```lua
local REG = setmetatable({}, { __mode = "k" })

local function for_buf(buf)
  local t = REG[buf]
  if not t then
    t = {}
    REG[buf] = t
    vim.api.nvim_create_autocmd("BufWipeout", {
      buffer = buf,
      once = true,
      callback = function() REG[buf] = nil end,
    })
  end
  return t
end
```

适合缓存“按缓冲区计算”的结果, 生命周期随 buffer 自动回收。

## 协程与异步模式

- 大纲
    - libuv 回调与 UI 线程
    - `vim.schedule()` 切回主循环
    - 定时器与防抖/节流
    - 结合现有代码的引用

### UI 线程与 schedule

- 原则: 在 libuv 回调里不要直接改 Neovim buffer/window 状态, 使用 `vim.schedule(function() ... end)` 切回主线程。
- 现有引用:
  - `lua/plugins/ide/telescope.lua:58-60` 在 `plenary.job` 的 `on_exit` 中通过 `vim.schedule` 写入 buffer。
  - `lua/plugins/ide/telescope.lua:66-75` 使用 `vim.loop.fs_stat` 异步获取文件大小后再决定是否调用预览器。

### 定时器与防抖

```lua
local function debounce(ms, fn)
  local timer = vim.loop.new_timer()
  return function(...)
    local argv = { ... }
    timer:stop()
    timer:start(ms, 0, function()
      vim.schedule(function() fn(unpack(argv)) end)
    end)
  end
end
```

场景: 频繁事件(如 TextChanged、CursorHold)触发的代价较高操作。

### 协程简述

- Lua 协程可用于顺序风格包装回调地狱, 但在 Neovim 中通常优先使用现有异步 API + schedule；协程适合本地计算流程, 不直接操作 UI。

## 健康检查与 OS gating

- 大纲
    - `vim.health` 统一接口
    - 命令可用性检测
    - OS gating 模式

### health 接口与现有引用

- 统一接口: `vim.health.start|ok|warn|error`(或旧版 `report_*`)。
- 现有实现: `lua/utils/health.lua:9-13` 做了兼容别名；`17-21` 检查版本；`23-58` 批量检测外部命令。

### OS gating 模式

```lua
local uname = vim.loop.os_uname().sysname  -- e.g. "Darwin"/"Linux"/"Windows_NT"
local is_mac = vim.fn.has("mac") == 1

local function has(cmd)
  return vim.fn.executable(cmd) == 1
end

if is_mac and not has("im-select") then
  vim.health.warn("`im-select` not found on macOS; input method sync disabled")
end
```

要点:

- 仅对目标 OS 检测特定依赖, 避免在其他 OS 上产生噪音警告。
- 通过 `pcall(require, ...)` 做可选依赖降级, 结合 `vim.health.warn` 告知用户。

---

## 附录: 风险清单与行动建议(阶段版)

- 保留 DSL, 替换装载器
    - 把 `bind.nvim_load_mapping()` 的底座改为 `vim.keymap.set`, 解决回调丢失。
- 避免破坏性读取
    - `keymap.lua` 的 `get_map()`/`replace()` 逻辑优先改为“非破坏式回退”。
- 增强 desc 与 buffer 语义
    - 全量使用 `vim.keymap.set` 的 `desc` 与 `buffer` 选项, 提高可观察性与隔离度。

---

## 下一步

- 如认可“前两节”的方向, 我将补齐余下部分：
    - require/模块缓存与命名空间
    - 弱表缓存模式与 memoize
    - 协程/异步与 UI 交互
    - 健康检查的模块化与 OS gating 模板
- 也可选择在 `~/.config/nv-tmp/` 建立一个最小可运行示例, 便于对照实验。
