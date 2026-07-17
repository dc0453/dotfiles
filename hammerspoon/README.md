# Hammerspoon 配置

这份配置用于快捷键驱动的应用切换、窗口循环和鼠标窗口操作。`~/.hammerspoon` 应链接到本目录；保存 Lua 文件后，Hammerspoon 会自动重载配置。

它与 [Karabiner-Elements](https://karabiner-elements.pqrs.org/) 配合使用：右 Option 作为 Hyper，右 Command 作为四修饰键组合。

# Features

- 保存 `.lua` 文件自动重载 Hammerspoon
- 启用 `hs.ipc`，可通过 `hs` 命令行客户端执行 Hammerspoon 命令
- 右 Option Hyper 快捷键启动或切换 Zoom
- 右 Command 快捷键循环 CatPaw IDE 和 Google Chrome 窗口
- 通用窗口选择器菜单
- SkyRocket 鼠标移动和缩放窗口
- 已保留但未启用的 Spoons

# Additional details and usage

## Hyper and hotkeys

本配置中有两组修饰键：

- **Hyper**：<kbd>control</kbd> + <kbd>option</kbd> + <kbd>command</kbd>。右 <kbd>Option</kbd> 由 Karabiner 映射为该组合。
- **右 Command**：<kbd>shift</kbd> + <kbd>control</kbd> + <kbd>option</kbd> + <kbd>command</kbd>。映射见 [`../karabiner/complex_modifications/hyper-key.json`](../karabiner/complex_modifications/hyper-key.json)。

### Karabiner configuration

启用 Karabiner 后需同时加载右 Option 与右 Command 的映射：

- 右 <kbd>Option</kbd>：发送 Hyper（<kbd>control</kbd> + <kbd>option</kbd> + <kbd>command</kbd>）。
- 右 <kbd>Command</kbd>：发送 <kbd>shift</kbd> + <kbd>control</kbd> + <kbd>option</kbd> + <kbd>command</kbd>。

右 Command 的规则文件会屏蔽该四修饰键与 <kbd>,</kbd>、<kbd>.</kbd>、<kbd>/</kbd> 的 macOS `sysdiagnose` 冲突。

### Launcher

`openswitch(name)` 返回一个可以直接绑定给快捷键的函数：目标应用不在前台时打开或聚焦；已在前台时交由 `switcherfunc()` 切换该应用的常规窗口。

当前启用的应用快捷键：

- 右 <kbd>Option</kbd> + <kbd>Z</kbd>：打开、聚焦或切换 `zoom.us`。

### Per-application window cycle

[`window_cycle.lua`](window_cycle.lua) 是独立的窗口循环模块。调用方式与 `openswitch(name)` 一致：

```lua
local windowCycle = require("window_cycle")
hs.hotkey.bind(modifiers, key, windowCycle("Application Name"))
```

当前绑定：

- 右 <kbd>Command</kbd> + <kbd>P</kbd>：循环 `CatPaw IDE` 窗口。
- 右 <kbd>Command</kbd> + <kbd>C</kbd>：循环 `Google Chrome` 窗口。

模块优先使用 AppleScript、应用的 Window 菜单和全屏 Space 兜底，以支持 Chrome 的跨全屏窗口切换。对于 CatPaw IDE 等不支持 AppleScript 窗口枚举的 Electron 应用，会自动降级为 Hammerspoon 原生 `hs.window.filter` 窗口列表。

应用名必须与 `hs.application:name()` 一致。排障时可将 `window_cycle.lua` 顶部的 `TRACE_ENABLED` 改为 `true`，在 Hammerspoon Console 输出各阶段耗时。

## App Switcher

[`switcher.lua`](switcher.lua) 提供所有应用的窗口选择菜单：

- <kbd>option</kbd> + <kbd>B</kbd>：显示所有可切换窗口。
- <kbd>option</kbd> + <kbd>shift</kbd> + <kbd>B</kbd>：显示当前应用的可切换窗口。

它基于 Hammerspoon 原生窗口过滤器维护窗口列表，因此能够展示 CatPaw IDE 等不支持 AppleScript 的应用。

## SkyRocket

[SkyRocket Spoon](https://github.com/dbalatero/SkyRocket.spoon) 已启用：

- <kbd>control</kbd> + <kbd>shift</kbd> + 鼠标拖动：移动窗口。
- <kbd>option</kbd> + <kbd>shift</kbd> + 鼠标拖动：缩放窗口。

## Disabled Spoons

以下组件在仓库中保留，但当前 `init.lua` 未启用：

- MiroWindowsManager
- MicMute
- RoundedCorners
- ArrangeDesktop、DeepLTranslate、HSKeybindings、Hotkeys、KSheet

# Install

1. 安装 [Hammerspoon](https://www.hammerspoon.org/) 并授予辅助功能权限；窗口循环的原生降级路径依赖该权限。
2. 在仓库根目录执行 `hammerspoon/install.sh`，它会将 `~/.hammerspoon` 链接到本目录；如果目标是普通目录，会先创建带时间戳的备份。
3. 启动或重载 Hammerspoon。配置加载后会显示 `Config loaded`。

### Hammerspoon CLI

`init.lua` 已加载 `hs.ipc`。Hammerspoon 正在运行时，可使用应用内的 `hs` 客户端，例如：

```bash
hs -c 'hs.reload()'
```

### Karabiner config

导入或合并 [`../karabiner/complex_modifications/hyper-key.json`](../karabiner/complex_modifications/hyper-key.json) 中的右 Command 规则，并确保右 Option 的 Hyper 映射已在 Karabiner 中启用。完成后在 Karabiner-Elements 中重新加载规则。
