# animate.nvim

一个轻量的独立 Neovim 动画引擎。它使用可配置的时长和缓动函数，对数值进行插值动画。

[English](README.md)

## 环境要求

- Neovim 0.10 或更新版本。

## 安装

项目托管于 Codeberg：<https://codeberg.org/aevre/animate.nvim>。

使用 lazy.nvim：

```lua
{
  "https://codeberg.org/aevre/animate.nvim",
  opts = {},
}
```

## 使用

```lua
local animate = require("animate")

animate.setup({
  duration = { step = 10, total = 200 },
  easing = "outQuad",
})

local animation = animate(0, 100, function(value, ctx)
  print(value, ctx.done)
end, {
  int = true,
  id = "example",
})

animation:stop()
```

模块可以直接调用，等价于 `animate.add(from, to, callback, opts)`。如果新动画使用已有 `id`，之前的同 ID 动画会先停止。

## 配置

`setup()` 设置共享默认值；每个动画的选项会覆盖共享配置。

| 选项 | 默认值 | 说明 |
| --- | --- | --- |
| `duration` | `20` | 每单位的毫秒数，或 `{ step, total }`。 |
| `easing` | `"linear"` | 缓动名称或函数。 |
| `fps` | `120` | 目标定时器最小间隔。 |
| `int` | 未设置 | 将回调值四舍五入为整数。 |
| `id` | 自动生成 | 用于替换活动动画的标识符。 |
| `buf` | 未设置 | `enabled()` 检查使用的 buffer。 |

时长表中的 `step` 表示每单位时长，`total` 是可选的总时长上限。只设置 `total` 时使用固定总时长。

## API

```lua
animate.setup(opts?)
animate.add(from, to, callback, opts?)
animate(from, to, callback, opts?)
animate.del(id)
animate.enabled(opts?)
```

回调接收 `(value, ctx)`。`ctx.animation` 是动画对象，`ctx.prev` 是前一个值，`ctx.done` 在最后一次回调时为 true。

内置缓动名称包括 `linear`、`inQuad`、`outQuad`、`inOutQuad`、`inCubic`、`outCubic`、`inSine`、`outSine`、`inBack` 和 `outBack`。自定义缓动函数接收 `(time, begin, change, duration)`。

`enabled({ name = "scroll", buf = bufnr })` 会检查 `vim.b[buf].core_animate` 和 `vim.b[buf].core_animate_scroll`，不存在时回退到对应的全局变量。这样集成模块可以提供 buffer 或全局级别的开关，而不依赖配置框架。
