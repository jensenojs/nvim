# `config/environment.lua` - 环境感知代码的中心枢纽

## 概述

`config/environment.lua` 模块是整个 Neovim 配置的环境感知中心。它提供了一个统一的接口来访问与运行环境相关的信息，包括：

- **平台检测**: 检测操作系统 (macOS, Linux, Windows, WSL)。
- **可执行文件检查**: 提供一个 `has` 表，用于检查系统上是否安装了特定的可执行文件。
- **环境变量访问**: 提供对常用环境变量的访问。
- **路径计算**: 计算 Neovim 的标准路径。
- **模式检测**: 检测离线模式和最小模式。

通过集中管理这些环境信息，该模块有助于提高配置的可维护性、一致性和性能。

## 设计原则

1. **统一访问**: 所有环境相关的查询都应该通过这个模块进行。
2. **延迟加载**: 环境信息在模块首次被 `require` 时计算一次，之后直接返回缓存的结果。
3. **只读**: 该模块导出的表是只读的，防止外部代码意外修改环境信息。
4. **可扩展**: 可以方便地添加新的环境检测功能。

## 核心功能

### 平台检测

```lua
local env = require("config.environment")

if env.is_mac then
  -- macOS 特定配置
elseif env.is_linux then
  -- Linux 特定配置
elseif env.is_windows then
  -- Windows 特定配置
end

if env.is_wsl then
  -- WSL 特定配置
end
```

### 可执行文件检查

`env.has` 表提供了一种简洁的方法来检查可执行文件是否存在。

```lua
local env = require("config.environment")

if env.has.git then
  -- 配置依赖 git 的功能
end

if env.has.python3 then
  -- 配置依赖 python3 的功能
end
```

支持的可执行文件检查列表：

- `git`
- `rg`
- `fd` / `fdfind`
- `nvr`
- `im_select` (im-select)
- `btop`
- `qwen`
- `opencode`
- `uv`
- `python3`

### 环境变量访问

该模块提供了对常用环境变量的访问。

```lua
local env = require("config.environment")

local venv_path = env.virtual_env
local conda_path = env.conda_prefix
local pip_proxy = env.pip_proxy
local api_key = env.CODESTRAL_API_KEY
```

支持的环境变量：

- `virtual_env` (来自 `VIRTUAL_ENV`)
- `conda_prefix` (来自 `CONDA_PREFIX`)
- `pip_proxy` (来自 `PIP_PROXY`)
- `CODESTRAL_API_KEY` (来自 `CODESTRAL_API_KEY`)

### 路径计算

`env` 表还提供了一些常用的路径。

```lua
local env = require("config.environment")

local cache_dir = env.cache_dir
local config_dir = env.vim_path
local home_dir = env.home
```

可用的路径：

- `is_mac`, `is_linux`, `is_windows`, `is_wsl`: 平台标志
- `vim_path`: Neovim 配置目录 (`stdpath('config')`)
- `cache_dir`: Neovim 缓存目录
- `modules_dir`: Neovim 模块目录
- `home`: 用户主目录
- `data_dir`: Neovim 数据目录

### 模式检测

```lua
local env = require("config.environment")

if env.offline then
  -- 离线模式配置
end

if env.minimal_mode then
  -- 最小模式配置
end
```

## 使用示例

在其他 Lua 模块中，通过 `require` 来使用环境模块：

```lua
-- my_plugin.lua
local env = require("config.environment")

-- 检查平台
if env.is_mac then
  -- macOS 配置
end

-- 检查可执行文件
if env.has.git then
  -- 启用 git 相关功能
end

-- 访问环境变量
if env.virtual_env then
  -- 配置虚拟环境相关路径
end

-- 使用路径
vim.opt.backupdir = env.cache_dir .. "/backup"
```

## 扩展

要添加新的环境检测功能，可以在 `compute` 函数中添加新的字段，并在 `M` 表中添加新的只读属性。

例如，要添加对 `NODE_ENV` 环境变量的支持：

1. 在 `compute` 函数中添加：

    ```lua
    t.node_env = os.getenv("NODE_ENV")
    ```

2. 现在就可以通过 `env.node_env` 来访问它了。

要添加新的可执行文件检查：

1. 在 `M.has` 表中添加：

    ```lua
    node = has("node"),
    ```

2. 现在就可以通过 `env.has.node` 来检查 `node` 是否存在。

## 总结

通过使用 `config/environment.lua` 作为环境感知的中心枢纽，我们可以构建一个更加健壮、可维护和可移植的 Neovim 配置。所有与环境相关的逻辑都集中在一个地方，使得配置更容易理解和修改。
