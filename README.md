# animate.nvim

A small standalone animation engine for Neovim. It interpolates numeric values with configurable duration and easing functions.

[简体中文](README.zh-CN.md)

## Requirements

- Neovim 0.10 or newer.

## Installation

The canonical repository is hosted on Codeberg: <https://codeberg.org/aevre/animate.nvim>.

With lazy.nvim:

```lua
{
  "https://codeberg.org/aevre/animate.nvim",
  opts = {},
}
```

## Usage

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

The module is callable and is equivalent to `animate.add(from, to, callback, opts)`. A new animation with an existing `id` stops the previous animation first.

## Configuration

`setup()` sets shared defaults. Per-animation options override them.

| Option | Default | Description |
| --- | --- | --- |
| `duration` | `20` | A number for milliseconds per unit, or `{ step, total }`. |
| `easing` | `"linear"` | An easing name or a function. |
| `fps` | `120` | Minimum timer interval target. |
| `int` | unset | Round callback values to integers. |
| `id` | generated | Identifier used to replace an active animation. |
| `buf` | unset | Buffer used by `enabled()` checks. |

Duration tables use `step` as the per-unit duration and `total` as an optional cap. When only `total` is set, the animation uses a fixed total duration.

## API

```lua
animate.setup(opts?)
animate.add(from, to, callback, opts?)
animate(from, to, callback, opts?)
animate.del(id)
animate.enabled(opts?)
```

The callback receives `(value, ctx)`. `ctx.animation` is the animation object, `ctx.prev` is the previous value, and `ctx.done` is true for the final callback.

Built-in easing names include `linear`, `inQuad`, `outQuad`, `inOutQuad`, `inCubic`, `outCubic`, `inSine`, `outSine`, `inBack`, and `outBack`. Custom easing functions receive `(time, begin, change, duration)`.

`enabled({ name = "scroll", buf = bufnr })` checks `vim.b[buf].core_animate` and `vim.b[buf].core_animate_scroll`, falling back to the corresponding global variables. This lets integrations provide buffer- or global-level switches without depending on a configuration framework.
