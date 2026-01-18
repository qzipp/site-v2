-- inspired by https://github.com/kikito/ansicolors.lua

local Object = require("core").Object

---@class kitty.Color: luvit.core.Object
local Color = Object:extend()

---@alias kitty.Color.Ansi
---| "reset"
---| "bright"
---| "dim"
---| "underline"
---| "blink"
---| "reverse"
---| "hidden"
---| "black"
---| "red"
---| "green"
---| "yellow"
---| "blue"
---| "magenta"
---| "cyan"
---| "white"
---| "blackbg"
---| "redbg"
---| "greenbg"
---| "yellowbg"
---| "bluebg"
---| "magentabg"
---| "cyanbg"
---| "whitebg"

Color.ansi = {
  reset = 0,

  bright = 1,
  dim = 2,
  underline = 4,
  blink = 5,
  reverse = 7,
  hidden = 8,

  black = 30,
  red = 31,
  green = 32,
  yellow = 33,
  blue = 34,
  magenta = 35,
  cyan = 36,
  white = 37,

  blackbg = 40,
  redbg = 41,
  greenbg = 42,
  yellowbg = 43,
  bluebg = 44,
  magentabg = 45,
  cyanbg = 46,
  whitebg = 47
}

-- ansi control code
---@param n number
function Color:to_ansicode(n)
  return (string.char(27) .. "[%sm"):format(tostring(n))
end


---@param text string
function Color:format(text)
  local out, count = text:gsub("%&{(.*)}", function(colors_str)
    ---@type string
    colors_str = colors_str

    local formatted = ""
    for v, _ in colors_str:gmatch("([^%s]+)") do ::continue::
      local ansi = Color.ansi[v]
      
      if not ansi then goto continue end

      local ansicode = Color:to_ansicode(ansi)
      formatted = formatted .. ansicode
    end
    
    return formatted
  end)

  return out .. Color:to_ansicode(Color.ansi.reset)
end

---@param color_name kitty.Color.Ansi
---@param text string
function Color:color(color_name, text)
  local ansi = Color.ansi[color_name]
  if not ansi then
    return ""
  end

  local ansicode = Color:to_ansicode(ansi)
  return ansicode .. text .. Color:to_ansicode(Color.ansi.reset)
end

return Color