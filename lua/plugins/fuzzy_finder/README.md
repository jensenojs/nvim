# Fuzzy Finder 插件模块

意图: 模糊搜索和文件查找功能。

## 插件列表

### telescope.lua
- 插件: `nvim-telescope/telescope.nvim`
- 仓库: https://github.com/nvim-telescope/telescope.nvim
- 功能: 高度可扩展的模糊查找器
- 配置特点:
  - 集成fzf-native提高搜索性能
  - 支持多种查找器（文件、缓冲区、grep等）
  - 丰富的自定义选项和主题

### lsp_takeover.lua
- 插件: 自定义配置
- 功能: LSP功能与Telescope集成
- 配置特点:
  - 在LSP附加时覆盖相关键位
  - 使用Telescope UI替代原生LSP界面
  - 提供统一的符号查找体验

## 使用说明

### Telescope 使用说明

Telescope 是Neovim中最强大的模糊查找器之一，提供了多种查找功能：

#### 核心功能
- 文件查找 (`<C-p>`)
- 当前文件内容搜索 (`<leader>/`)
- 全局内容搜索 (`<leader><C-/>`)
- Git状态查看 (`<leader>g`)
- 寄存器查看 (`<leader>r`)

#### 配置特点
1. 预览设置：
   - 忽略大于1MB的文件
   - 不预览二进制文件
   - 智能文件类型检测

2. 搜索优化：
   - 集成fzf-native提高性能
   - 自定义忽略模式（忽略.git目录、二进制文件等）
   - 智能大小写匹配

3. 界面定制：
   - 自定义布局配置
   - 支持水平和垂直布局
   - 可调整窗口大小和位置

#### 快捷键
- `<C-p>`: 查找文件
- `<leader>/`: 模糊搜索当前文件
- `<leader><C-/>`: 全局模糊搜索
- `<leader>g`: 列出当前项目下修改了哪些文件
- `<leader>r`: 打开寄存器列表

### LSP 与 Telescope 集成

LSP takeover 模块会在LSP附加到缓冲区时，使用Telescope覆盖原生的LSP键位映射：

#### 覆盖的键位
- `gd`: 跳转到定义（使用Telescope界面）
- `gi`: 跳转到实现
- `gr`: 查找引用
- `gt`: 跳转到类型定义
- `<leader>o`: 当前文件符号查找
- `<leader>O`: 工作区符号查找
- `<C-t>`: 在工作区查找当前光标下的符号
- `<leader>dl`: 当前文件诊断列表
- `<leader>dL`: 工作区诊断列表
- `<leader>lca`: Code Action
- `<leader>lci`: 查找被谁调用
- `<leader>lco`: 查找调用谁

#### 集成优势
1. 统一的UI体验：所有LSP相关功能都通过Telescope界面展示
2. 更好的可视化：Telescope提供了更好的搜索和筛选能力
3. 幂等性：确保同一缓冲区不会重复设置键位映射
4. 兼容性：自动处理延迟加载的情况，确保已附加LSP的缓冲区也能正确设置

### 使用技巧

1. 在Telescope界面中：
   - `<C-h>` 或 `<F1>`: 显示可用快捷键
   - `<CR>`: 选择项目并关闭
   - `<C-u>`: 清空搜索框
   - `<C-d>`: 删除缓冲区（在缓冲区查找器中）

2. 搜索技巧：
   - 使用空格分隔多个关键词进行模糊匹配
   - 使用`!`排除特定模式
   - 使用`^`和`$`进行精确匹配

3. 文件查找优化：
   - 使用fd作为默认查找命令提高性能
   - 自定义忽略模式避免搜索不必要的文件