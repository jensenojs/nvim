# File 插件模块

意图: 文件管理、搜索和大文件处理。

## 插件列表

### yazi.lua
- 插件: `mikavilpas/yazi.nvim`
- 仓库: https://github.com/mikavilpas/yazi.nvim
- 功能: Neovim与Yazi文件管理器的集成
- 配置特点:
  - 提供文件浏览和选择功能
  - 支持相对路径解析
  - 与grug-far集成进行查找和替换

### grug-far.lua
- 插件: `MagicDuck/grug-far.nvim`
- 仓库: https://github.com/MagicDuck/grug-far.nvim
- 功能: Neovim中的查找和替换工具
- 配置特点:
  - 提供项目范围的查找和替换
  - 与Yazi集成

### bigfile.lua
- 插件: `LunarVim/bigfile.nvim`
- 仓库: https://github.com/LunarVim/bigfile.nvim
- 功能: 大文件优化处理
- 配置特点:
  - 自动检测大文件并应用优化配置
  - 禁用某些影响性能的插件
  - 提供大文件友好的编辑体验

### temporary_file.lua
- 插件: 自定义配置
- 功能: 临时文件管理
- 配置特点:
  - 自动识别和处理临时文件
  - 提供临时文件特定的配置

## 使用说明

### Yazi 集成使用说明

Yazi 是一个现代化的终端文件管理器，通过此插件可以在Neovim中方便地使用它：

快捷键：
- `<leader>y`: 在当前文件位置打开Yazi
- `<leader>Y`: 在当前工作目录打开Yazi

特性：
- 支持文件选择和导航
- 可以复制相对路径
- 与Neovim编辑器无缝集成

### Grug FAR 使用说明

Grug FAR (Find And Replace) 提供了强大的查找和替换功能：

特性：
- 支持正则表达式
- 可视化替换预览
- 支持批量替换操作
- 与Yazi集成，可以从文件管理器直接调用

### 大文件处理

Bigfile 插件会自动检测大文件（默认1.5MB以上）并应用优化配置：

优化措施：
- 禁用语法高亮
- 禁用行号显示
- 禁用相对行号
- 禁用代码折叠
- 禁用某些影响性能的插件
- 启用快速模式

这样可以确保在编辑大文件时仍然保持流畅的体验。

### 临时文件管理

临时文件管理器会自动识别临时文件（如位于/tmp目录下的文件），并应用特定的配置：

特性：
- 简化的编辑环境
- 针对临时文件优化的设置
- 自动清理机制