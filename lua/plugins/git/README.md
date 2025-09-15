# Git 插件模块

意图: Git集成和版本控制功能。

## 插件列表

### gitsigns.lua
- 插件: `lewis6991/gitsigns.nvim`
- 仓库: https://github.com/lewis6991/gitsigns.nvim
- 功能: 在标志列显示Git变更标记，并提供丰富操作
- 配置特点:
  - 显示添加、修改、删除的行标记
  - 提供导航和操作功能
  - 支持 blame 和 diff 功能

### lazygit.lua
- 插件: `kdheepak/lazygit.nvim`
- 仓库: https://github.com/kdheepak/lazygit.nvim
- 功能: 在Neovim中集成LazyGit终端界面
- 配置特点:
  - 提供LazyGit命令
  - 与Neovim键位绑定集成

### git-blame.lua
- 插件: `f-person/git-blame.nvim`
- 仓库: https://github.com/f-person/git-blame.nvim
- 功能: 当前行虚拟文本Blame信息显示
- 配置特点:
  - 在当前行显示Git Blame信息
  - 不干扰编辑体验

## 使用说明

### Gitsigns 使用说明

Gitsigns 提供了完整的Git集成体验，在编辑器中直接显示Git状态：

#### 核心功能
1. 行状态标记：
   - 添加的行用绿色标记
   - 修改的行用蓝色标记
   - 删除的行用红色标记

2. 导航功能：
   - 跳转到下一个/上一个变更块

3. 操作功能：
   - 暂存/重置单个变更块
   - 预览变更内容
   - 查看Blame信息
   - 比较差异

#### 使用方法
虽然当前配置中禁用了键位映射，但可以通过以下方式使用：
- 调用 `:Gitsigns` 命令访问各种功能
- 使用 `require('gitsigns').` API直接调用函数

### LazyGit 集成使用说明

LazyGit 是一个终端中的Git界面，通过此插件可以在Neovim中方便地使用它：

#### 快捷键
- `<leader>G`: 打开LazyGit界面

#### 功能
LazyGit提供了完整的Git操作界面：
- 提交和推送
- 分支管理
- 合并和变基
- stash管理
- 日志查看

### Git Blame 使用说明

Git Blame 插件会在当前行显示Git Blame信息：

#### 功能
- 在当前行的虚拟文本中显示Blame信息
- 包含提交哈希、作者和时间信息
- 不干扰正常的编辑操作

#### 使用方法
- 自动在当前行显示Blame信息
- 可以通过配置禁用或自定义显示格式

### 工作流程建议

1. 日常编辑时：
   - 通过Gitsigns标记快速识别变更位置
   - 使用LazyGit进行复杂的Git操作

2. 代码审查时：
   - 使用Gitsigns导航到变更位置
   - 查看Blame信息了解变更历史
   - 使用LazyGit查看完整提交历史

3. 提交前检查：
   - 使用Gitsigns预览所有变更
   - 通过LazyGit进行交互式暂存和提交