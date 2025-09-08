# Neovim 配置重构：Lua 基础与 lazy.nvim 最佳实践学习要点

## 1. Lua 基础知识 (针对 Neovim 配置)

为了完全掌控你的 Neovim 配置, 理解 Lua 的核心概念至关重要。以下是你需要重点掌握的基础知识：

### 1.1. 变量与作用域

- **局部变量 (`local`)**: 在函数或块内声明, 提高性能和避免命名冲突。这是推荐做法。

  ```lua
  local my_var = "value"
  ```

- **全局变量**: 避免直接创建全局变量。Neovim 提供了特定的表来管理不同作用域的变量：
    - `vim.g.my_global_var = "value"` (对应 Vimscript 的 `g:`)
    - `vim.b.my_buffer_var = "value"` (对应 `b:`)
    - `vim.w.my_window_var = "value"` (对应 `w:`)
    - `vim.t.my_tab_var = "value"` (对应 `t:`)
    - `vim.env.MY_ENV_VAR = "value"` (访问/设置环境变量)

### 1.2. 函数

- **定义**: 使用 `function` 关键字。

  ```lua
  local function my_function(arg1, arg2)
    print(arg1 .. " " .. arg2)
    return arg1 .. arg2
  end
  ```

- **调用**: 直接使用函数名加括号。

  ```lua
  local result = my_function("Hello", "World")
  ```

### 1.3. 表 (Tables)

- **核心数据结构**: Lua 中唯一的复合数据结构, 可以作为数组、字典(哈希表)、对象或命名空间使用。
- **创建**:

  ```lua
  local my_array = { "item1", "item2", "item3" } -- 数组(索引从 1 开始)
  local my_dict = { key1 = "value1", key2 = "value2" } -- 字典
  local mixed = { "item1", key1 = "value1" } -- 混合
  ```

- **访问**:

  ```lua
  print(my_array[1]) -- 访问数组元素 (注意索引从 1 开始)
  print(my_dict["key1"]) -- 通过字符串键访问
  print(my_dict.key1) -- 通过点号访问 (等同于 ["key1"])
  ```

### 1.4. 模块与 `require`

- **模块化**: 将代码分割成独立的 `.lua` 文件, 每个文件返回一个表(模块)。

  ```lua
  -- mymodule.lua
  local M = {}
  M.my_value = 42
  function M.my_function()
    return "Hello from mymodule"
  end
  return M -- 返回模块表
  ```

- **导入**: 使用 `require` 加载模块。模块路径基于 `runtimepath` 下的 `lua/` 目录。

  ```lua
  -- main.lua
  local mymodule = require("mymodule") -- 不需要 .lua 扩展名
  print(mymodule.my_value)
  print(mymodule.my_function())
  ```

- **缓存**: `require` 会对模块进行缓存, 多次调用 `require` 会返回同一个实例。

### 1.5. 常用 Neovim API

- **`vim.api.*`**: 调用 Neovim 的核心 API, 如创建自动命令、管理缓冲区、窗口等。
    - `vim.api.nvim_create_autocmd(...)`
    - `vim.api.nvim_buf_set_option(...)`
- **`vim.opt.*`**: 访问和设置 Neovim 选项。
    - `vim.opt.number = true` (等同于 `:set number`)
    - `vim.opt.expandtab = false`
- **`vim.keymap.set`**: 设置键位映射 (推荐使用这个而不是旧的 `:map` 命令)。
    - `vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = "Save" })`

## 2. `lazy.nvim` 最佳实践

`lazy.nvim` 是现代 Neovim 配置的核心, 掌握其最佳实践能让你的配置更高效、更易维护。

### 2.1. 插件规范 (Plugin Spec) 结构

- **清晰的结构**: 每个插件配置应尽可能清晰、简洁。

  ```lua
  return {
    "author/plugin-name",
    -- 其他配置项...
  }
  ```

- **`opts` vs `config`**:
    - **优先使用 `opts`**: 如果插件遵循 `require("plugin").setup(opts)` 模式, 直接使用 `opts` 是最简洁高效的方式。`lazy.nvim` 会自动调用 `setup`。

    ```lua
    return {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = { "lua", "python" },
        highlight = { enable = true },
      }
    }
    ```
    - **使用 `config` 处理复杂逻辑**: 当你需要执行更复杂的初始化代码, 或者插件没有标准的 `setup` 函数时, 使用 `config`。

    ```lua
    return {
      "folke/which-key.nvim",
      config = function()
        require("which-key").setup({
          -- more complex setup
        })
        -- 可以在这里添加额外的键位映射等
      end
    }
    ```

- **明确声明 `dependencies`**: 如果你的插件需要其他插件才能正常工作, 请在 `dependencies` 中列出它们。

  ```lua
    return {
      "L3MON4D3/LuaSnip",
      dependencies = { "rafamadriz/friendly-snippets" },
      -- ...
    }
    ```

### 2.2. 懒加载 (Lazy Loading) 策略

- **核心思想**: 只在真正需要时才加载插件, 极大提升启动速度。
- **使用触发器**:
    - `event`: 基于 Neovim 事件。例如 `event = "BufReadPre"` 表示在读取文件前加载 LSP 插件。
    - `ft`: 基于文件类型。例如 `ft = "python"` 表示打开 Python 文件时加载相关插件。
    - `cmd`: 基于命令。例如 `cmd = "Telescope"` 表示输入 `:Telescope` 命令时加载。
    - `keys`: 基于按键。例如 `keys = { "<leader>f", "<cmd>Telescope find_files<cr>" }` 表示按下 `<leader>f` 时加载。
- **全局策略**: 在 `lazy.nvim` 的主配置中设置 `defaults.lazy = true`, 强制你为每个插件显式定义加载条件, 避免无意中加载不需要的插件。

### 2.3. 性能与组织

- **启用缓存**: 确保 `performance.cache.enabled = true`。
- **合理分组**: 将插件配置按功能分组存放在不同的目录下(如 `plugins/lsp/`, `plugins/completion/`, `plugins/ui/`), 这有助于管理和理解。
- **避免顶层副作用**: 插件配置文件的顶层(返回表之前)应尽量避免执行会产生副作用的代码(如设置键位、创建自动命令)。这些应该放在 `opts` 或 `config` 回调函数内。

## 3. 结合你的重构目标

- **模块化**: 利用 Lua 的模块系统和 `lazy.nvim` 的目录组织能力, 将配置分解为小的、职责单一的模块。
- **可扩展性**: 通过 `lazy.nvim` 的 `dependencies` 和 `cond` (条件加载) 功能, 以及清晰的模块设计, 使配置易于扩展。
- **自解释性**: 在 Lua 代码中添加必要的注释, 使用清晰的变量名和函数名。利用模块化结构本身就提高了可读性。
- **掌握核心技术**: 熟练使用 `vim.api.*`, `vim.opt.*`, `vim.keymap.set` 以及 `lazy.nvim` 的各项功能, 是你实现“完全把握配置”的基础。

通过深入学习和实践这些 Lua 和 `lazy.nvim` 的知识, 你将能够主导并成功完成这次大规模的 Neovim 配置重构。
