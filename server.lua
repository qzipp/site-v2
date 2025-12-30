_G.require = require
_G.Logger = require("./core/Logger")
function _G.trace(...)
  return _G.Logger:trace(...)
end

local Router = require('./core/Router')
-- local Request = require('./core/router/Request')
-- local FTML = require('./core/FTML')
-- local FuzzyFSRouter = require('./core/FuzzyFSRouter')
local App = require('./core/App')

local Static = require('./core/middlewares/Static')

-- local ftml = FTML:new({
--   directory = "./routes/"
-- })

-- local router = FuzzyFSRouter:new({
--   directory = "./routes/"
-- })

--- TODO
-- make a base extendable router
-- use the base router and extend for fuzzy app. 
-- use router and extend more for fs router
-- fs router will accept middlewares, like FTML

-- +PURPOSE[.format].lua

--use sqlite3, thsi is not that important to use pgsql
-- and use libs for like multipart or json idk :33333

-- local app = App:new()
-- app:use(router)

local app = App:new()

app:use(Static:new())
app:use(function(req, res)
  -- print(req.url)
end)

app:get("/", function(req, res)
  res:send("yawn")
end)
app:get("/t/:id", function(req, res)
  -- res:send("yawn", req.params.id)
end)

app:get("/funny", function(req, res)
  trace("zzz")
  res:send("yawn")
end)

app:start({
  port = 8000
})

--to enable debugging, use env DBG=1 in cli