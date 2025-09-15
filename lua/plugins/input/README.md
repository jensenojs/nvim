# Input 插件模块

意图: 输入法管理和输入增强功能。

## 插件列表

### im_select.lua
- 插件: `keaising/im-select.nvim`
- 仓库: https://github.com/daipeihust/im-select
- 功能: 自动切换输入法状态
- 配置特点:
  - 在进入插入模式时自动切换到英文输入法
  - 在退出插入模式时恢复之前的输入法状态
  - 依赖外部命令 `im-select`

## 使用说明

### IM Select 使用说明

IM Select 插件用于自动管理输入法状态，解决在编程时频繁切换输入法的问题。

#### 依赖要求
此插件依赖外部命令 `im-select`，需要先安装该工具：

**macOS:**
```bash
# 使用Homebrew安装
brew tap daipeihust/tap
brew install im-select
```

**Windows:**
```powershell
# 使用Scoop安装
scoop install im-select
```

**Linux:**
```bash
# 根据发行版选择安装方式
# Ubuntu/Debian:
sudo apt-get install im-select

# 或从源码编译
git clone https://github.com/daipeihust/im-select.git
cd im-select
make
sudo make install
```

#### 工作原理
1. 当进入插入模式时，自动切换到英文输入法
2. 当退出插入模式时，恢复到之前的输入法状态
3. 这样可以确保在正常编辑代码时使用英文输入法，而在使用命令模式时可以使用中文输入法

#### 配置说明
插件配置非常简单，只需要在 `im_select.lua` 中设置：
```lua
return {
  "keaising/im-select.nvim",
  event = "InsertEnter",
  opts = true,
}
```

这表示：
- 插件在进入插入模式时加载
- 使用默认配置（opts = true）

#### 使用场景
1. 编写代码时：自动保持英文输入法，避免输入特殊字符时出现问题
2. 注释编写时：可以自动切换到中文输入法
3. 命令模式时：可以使用中文输入法输入命令

#### 注意事项
1. 确保 `im-select` 命令在系统 PATH 中可用
2. 在某些系统中可能需要额外的权限配置
3. 如果遇到问题，可以尝试在终端中手动运行 `im-select` 命令测试是否正常工作