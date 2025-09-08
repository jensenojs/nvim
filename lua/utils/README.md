# utils 使用手册(tmp 版)

意图: 面向使用者的简明手册, 说明在 tmp 配置中直接使用 utils 的能力与常见场景。

- 将 tmp 路径置于 runtimepath 前, 让 `require("utils.*")` 优先解析到此目录。

```lua
vim.opt.runtimepath:prepend("/Users/jensen/.config/nvim/tmp")
local U = require("utils")
```

- 聚合入口能力: `require("utils")`
    - 工具: `quick_substitute`, `bind`, `keymap_adapter`, `icons`, `dap`, `health`
    - 配色与高亮: `get_palette`, `extend_hl`, `blend`, `hl_to_rgb`
    - 配置工具: `tobool`, `extend_config`, `load_plugin`

---

- 快速替换(选区/行/缓冲区)

```lua
-- 默认绑定: v/<leader>s, n/<leader>ss(当前行), n/<leader>sS(全缓冲区)
U.quick_substitute.setup()

-- 自定义键位
-- U.quick_substitute.setup({ keys = { visual = "gr", line = "grr", buffer = "grR" } })
-- 或禁用自动绑定
-- U.quick_substitute.setup({ keys = false })
```

- 批量键位定义(bind DSL)

```lua
local b = U.bind
b.nvim_load_mapping({
  ["n|<leader>qq"] = b.map_callback(function() print("hi") end):with_desc("Demo"),
  ["v|<leader>y"]  = b.map_cmd('"+y'):with_desc("Yank to system clipboard"),
})
```

- 渐进式适配旧映射(keymap_adapter)

```lua
U.keymap_adapter.replace("n", "<leader>aa", function()
  print("new behavior")
end, { desc = "Adapter demo" })
```

- 调试参数采集(dap 工具)

```lua
-- 在 nvim-dap 配置中使用惰性多层函数形式
program = function() return U.dap.pick_executable()()() end,
args    = function() return U.dap.input_args()()() end,
env     = function() return U.dap.get_env() end,
```

- 图标与界面文案(icons)

```lua
local icons = U.icons.get("ui", true)
print(icons.Check)
```

- 配色与高亮

```lua
local p = U.get_palette()
U.extend_hl("Search", { bg = p.yellow })
```

- 健康检查(health, Kickstart 风格)

```lua
-- 统一从聚合入口调用
U.health.check()
-- 或直接: require("utils").health.check()
```

注意事项:

- 旧版正式目录保持不变; 本目录仅在 tmp 中生效。
- 模块 require 零副作用; 只有 `setup()` 或显式调用才会生效。
- 键位绑定统一使用 `vim.keymap.set`, 并提供合理的 `desc`。

后续: 本 README 将持续补充更多场景示例与最佳实践。
