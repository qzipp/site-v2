local Object = require("core").Object

local FS = require("fs")

---@class fuzzy.middlewares.Static: fuzzy.router.Middleware
local Static = Object:extend()

function Static:initialize()
  self.file_dir = FS.readdirSync("./static")

  self.files = {}
  for i, f in pairs(self.file_dir) do
    local data, err = FS.readFileSync("./static/" .. f)
    self.files[f] = data
  end
end

function Static:call(req, res)
  for f, d in pairs(self.files) do
    if req.url == "/static/" .. f then
      res:send(d)
    end
  end
end

return Static