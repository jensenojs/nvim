# neotest 使用说明

参考: [neotest.txt 官方文档](https://github.com/nvim-neotest/neotest/blob/master/doc/neotest.txt)

## 目标

- 在各种语言下统一“发现-运行-调试-查看结果”的测试体验。
- 与 nvim-dap 集成, 实现对“最近的测试/单个用例”的断点调试。

## 本仓库当前配置概览

- 插件: `nvim-neotest/neotest`(见 `lua/plugins/test/neotest.lua`)
- 依赖: `nvim-nio`, `plenary.nvim`, `FixCursorHold.nvim`, `nvim-treesitter`
- 适配器:
    - Rust: `rustaceanvim.neotest`(依赖 rustaceanvim 提供的适配)
    - Go/C/C++/Python 等可按需增配对应 adapter(示例代码已在文件中预留注释)
- UI 行为:
    - diagnostics 使用 neotest 专有命名空间优化了 virtual_text 文本
    - 提供 Trouble 集成的 consumer, 测试失败为 0 时自动关闭 Trouble 面板

## 快捷键(见 neotest.lua 中的映射)

- 运行最近测试: `<space>tn`
- 调试最近测试: `<space>td`(strategy = "dap", 断点生效)
- 运行当前文件所有测试: `<space>tf`
- 运行整个项目测试: `<space>tA`
- 打开/关闭摘要树: `<space>ts`
- 打开最近一次运行的输出(进入窗口): `<space>to`
- 切换 watch(自动重跑): `<space>tw`(当前 buffer)/`<space>tW`(当前文件)
- 打开/关闭输出面板: `<space>tO`
- 停止正在运行的测试: `<space>tS`

## 常见使用场景

- 调试单个测试用例
  1. 在测试函数上设置断点
  2. 将光标置于该测试函数内
  3. 按 `<space>td` 使用 DAP 策略运行；命中断点后可步进/查看变量
- 查看失败原因
    - `<space>to` 打开输出, 或打开 Trouble 查看聚合问题(失败为 0 会自动关闭)
- 持续集成式开发
    - `<space>tw` 打开当前 buffer 的 watch, 文件改动后自动重跑最近的测试

## 适配器扩展

- Rust 已启用 `rustaceanvim.neotest`
- Go 示例(可在 `opts.adapters` 中启用, 需安装 adapter 与 dap-go):

```lua
["neotest-golang"] = {
  go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
  dap_go_enabled = true,
},
```

- C/C++ 可选用支持 GoogleTest/Catch2/CTest 的适配器, 或自定义命令行过滤；neotest 支持将“运行”切换为 `strategy = "dap"` 达成调试。

## 运行策略与 DAP

- `require("neotest").run.run({ strategy = "dap" })` 会以 dap 会话方式运行所选测试。
- 断点由 nvim-dap 管理, `dap-ui` 会随会话自动开启/关闭, 你的 `<F10>/<F11>/<F12>` 步进键照常可用。

## 注意事项

- 需要 Treesitter 解析以获取稳定的测试发现能力。
- 某些语言适配器需要额外依赖(例如 Go 的 golang/test 工具)。
- 如遇无法发现测试的情况, 先确认对应 adapter 已安装并被正确 setup。
