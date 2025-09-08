# Neovim调试配置指南

<https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation>

## 目录结构

```
lua/config/debug/
├── init.lua              # 表驱动配置注册和初始化(仅负责注册, 不含 UI)
├── c.lua                 # C：adapter + configurations(codelldb)
├── cpp.lua               # C++：adapter + configurations(codelldb)
├── rust.lua              # Rust：adapter + configurations(codelldb)
├── python.lua            # Python：adapter + configurations(debugpy)
├── go.lua                # Go：手动配置示例(当前交由 nvim-dap-go 管理, 文件内容已注释)
└── README.md             # 本文档
```

## 概述

本文档详细说明了如何在Neovim中配置和使用调试功能。调试功能基于Debug Adapter Protocol (DAP)实现, 通过nvim-dap插件提供支持。

## 核心概念

### 语言配置文件结构

每种语言的配置文件都采用统一的结构, 包含Adapter和Configuration两部分：

```lua
-- 示例：Go语言配置文件 (go.lua)
return {
  -- Adapter配置：定义如何启动调试器
  adapter = {
    type = "executable",
    command = "/path/to/dlv",
    args = {"dap", "-l", "127.0.0.1:38697"},
  },
  
  -- Configuration配置：定义调试场景
  configurations = {
    {
      type = "go",
      name = "Launch File",
      request = "launch",
      program = "${file}",
    },
    -- 更多配置...
  }
}
```

### 表驱动配置注册

在`init.lua`中使用表驱动方式统一注册所有语言配置(本模块只做“注册”, 不含 UI)：

```lua
local language_configs = {
  c = { module = "config.debug.c", debugger = "codelldb" },
  cpp = { module = "config.debug.cpp", debugger = "codelldb" },
  rust = { module = "config.debug.rust", debugger = "codelldb" },
  python = { module = "config.debug.python", debugger = "debugpy" },
}

for lang, config_info in pairs(language_configs) do
  if registry.is_installed(config_info.debugger) then
    local ok, lang_config = pcall(require, config_info.module)
    if ok and lang_config then
      -- 适配器注册：确保 adapters 的 key 与 configurations[*].type 完全一致
      if lang_config.adapter then
        local adapter_key = lang
        if type(lang_config.configurations) == "table" then
          for _, cfg in ipairs(lang_config.configurations) do
            if type(cfg) == "table" and type(cfg.type) == "string" and #cfg.type > 0 then
              adapter_key = cfg.type
              break
            end
          end
        end
        dap.adapters[adapter_key] = lang_config.adapter
      end

      -- 语言配置注册：按 &filetype 索引
      if lang_config.configurations then
        dap.configurations[lang] = lang_config.configurations
      end
    end
  end
end
```

## 配置协调机制

### 注册和匹配过程

1. **Adapter注册**：

   ```lua
   dap.adapters.go = { /* adapter配置 */ }
   ```

2. **Configuration注册**：

   ```lua
   dap.configurations.go = { /* configuration配置 */ }
   ```

3. **运行时匹配**：
   当用户选择一个调试配置时：
   - 查找配置中的`type`字段(如"go")
   - 根据`type`找到对应的Adapter配置
   - 启动Adapter指定的调试器
   - 将Configuration参数传递给调试器

### 表驱动配置模式

nvim-dap采用表驱动配置模式, 这是一种声明式的配置管理方式, 具有以下特点：

#### 1. 配置即数据

所有的配置都通过Lua表来定义, 而不是通过函数调用：

```lua
-- 语言配置映射表
local language_configs = {
  go = {
    module = "config.debug.go",
    debugger = "delve"
  },
  python = {
    module = "config.debug.python",
    debugger = "debugpy"
  }
}
```

#### 2. 批量处理能力

可以使用循环批量处理配置：

```lua
-- 批量注册所有语言配置
for lang, config_info in pairs(language_configs) do
  if registry.is_installed(config_info.debugger) then
    local lang_config = require(config_info.module)
    dap.adapters[lang] = lang_config.adapter
    dap.configurations[lang] = lang_config.configurations
  end
end
```

#### 3. 模块化组织

每种语言的配置集中在一个文件中(C/C++/Rust 已拆分)：

```
c.lua         # C: adapter + configurations(codelldb)
cpp.lua       # C++: adapter + configurations(codelldb)
rust.lua      # Rust: adapter + configurations(codelldb)
python.lua    # Python: adapter + configurations(debugpy)
go.lua        # Go: 手动示例；实际由 nvim-dap-go 提供
```

#### 4. 表驱动的优势

- **声明式**：配置是声明式的, 易于理解和维护
- **模块化**：每种语言配置独立, 便于管理
- **可扩展**：添加新语言支持只需添加新的配置文件
- **可测试**：表结构易于进行单元测试

## 工具函数使用

### utils.dap 模块

提供调试会话中常用的工具函数, 并提供一层闭包 API 以便延迟求值：

1. 直接函数(立即求值)：
   - `input_args()` 获取程序参数数组
   - `input_exec_path()` 获取可执行文件路径
   - `input_file_path()` 获取被调试文件路径
   - `get_env()` 获取环境变量数组

2. 闭包函数(延迟求值, 用于 nvim-dap 配置)：
   - `fn.input_args()`
   - `fn.input_exec_path()`
   - `fn.input_file_path()`
   - `fn.get_env()`

示例(新的推荐写法)：

```lua
dap.configurations.python = {
  {
    type = "python",
    name = "Launch with args",
    request = "launch",
    program = require("utils.dap").fn.input_file_path(),
    args    = require("utils.dap").fn.input_args(),
    cwd     = "${workspaceFolder}",
  }
}
```

注意：旧的“三层调用”风格(例如 `require("utils.dap").input_file_path()()()`)已被移除, 以简化心智负担。

### 统一的工作目录(cwd)

为保证一致的运行语义, 当前各语言的配置默认设置 `cwd = "${workspaceFolder}"`(包含 attach 场景)。
如需在某个配置中使用 `./${relativeFileDirname}` 等相对路径, 可在对应语言文件中局部覆盖。

## 添加新语言支持流程

### 1. 创建语言配置文件

在`lua/config/debug/`目录下创建新的语言配置文件：

```lua
-- example.lua
return {
  adapter = {
    type = "executable",
    command = "debugger-command",
    args = {"arguments"},
  },
  configurations = {
    {
      type = "example",
      name = "Launch File",
      request = "launch",
      program = require("utils.dap").input_file_path()(),
    }
  }
}
```

### 2. 更新初始化配置

在`init.lua`的`language_configs`表中添加新语言：

```lua
local language_configs = {
  -- ... existing languages ...
  example = {
    module = "config.debug.example",
    debugger = "example-debugger"
  }
}
```

### 3. 确保调试器已安装

通过mason安装对应的调试器：

```lua
-- 在lua/utils/mason-list.lua中添加
example = {
  servers = { /* LSP servers */ },
  tools = { "example-debugger" },
}
```

## 键位绑定

### 全局键位

- `F5` - 继续执行
- `F9` - 切换断点
- `F10` - 单步跳过
- `F11` - 单步进入
- `F12` - 单步跳出

### 调试会话期间键位

- 调试会话开始时可能覆盖某些LSP键位
- 调试会话结束时恢复原始键位

## 调试UI管理

### 生命周期管理

```lua
-- 调试会话开始时打开UI
dap.listeners.after.event_initialized["dapui"] = function()
  dapui.open()
end

-- 调试会话结束时关闭UI
dap.listeners.before.event_terminated["dapui"] = function()
  dapui.close()
end
```

## 常见问题和解决方案

### 调试器未找到

检查：

1. 调试器是否已通过mason安装
2. 调试器路径是否正确
3. 环境变量是否设置正确

### 配置不生效

检查：

1. 配置是否在正确的时机加载
2. Adapter和Configuration的type是否匹配
3. 是否有语法错误

### 调试会话无法启动

检查：

1. 端口是否被占用
2. 程序路径是否正确
3. 权限是否足够
