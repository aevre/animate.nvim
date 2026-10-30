---@alias animate.easing.Fn fun(time: number, begin: number, change: number, duration: number): number

---@class animate.Duration
---@field step? number duration step in ms
---@field total? number total duration in ms

---@class animate.Config
---@field duration? animate.Duration|number
---@field easing? string|animate.easing.Fn
---@field fps? number

---@class animate.Opts: animate.Config
---@field buf? number
---@field int? boolean Round values to integers
---@field id? number|string

---@class animate.Ctx
---@field done boolean
---@field animation animate.Animation
---@field prev number

---@alias animate.callback fun(value: number, ctx: animate.Ctx)

---@alias animate.easing.Name string
---@class animate.Easing
---@field [string] animate.easing.Fn

---@class animate.Animation
---@field id number|string
---@field easing animate.easing.Fn
---@field opts animate.Opts
---@field timer? uv.uv_timer_t
---@field steps? number[]
---@field _step? number
