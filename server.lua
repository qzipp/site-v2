_G.require = require
-- _G.Logger = require("./core/Logger")
function _G.trace(...)
  print(...)
  -- return _G.Logger:trace(...)
end

local Fuzzy = require('./libs/fuzzy/Fuzzy')
local Static = require('./libs/fuzzy/middlewares/Static')

local FileSystemRouter = require("./libs/fuzzy/routers/FileSystemRouter")

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

local app = Fuzzy.App:new()

--todo, support path
app:use(--[["/static/", ]]Static:new())
app:use(function(req, res)
  -- res:send("hi")
  -- print(req.url)
end)

local penis = FileSystemRouter:new({
  path = "/",
  directory = "./routes"
})

-- penis:get("/bai", function(req, res)
--   print("hiiii: ", req.url)
-- end)

app:mount(penis)

-- app:get("/", function(req, res)
--   res:send("yawn")
-- end)
-- app:get("/t/:id/:NEW", function(req, res)
--   res:send("yawn PARAMS " .. req.params.id .. " " .. req.params.NEW)
-- end)


-- app:get("/a-:bwa", function(req, res)
--   trace(req.params.bwa)
--   if req.params.bwa == "meow" then
--     res:send("hi")
--   end
  
--   res:pass()
-- end)

-- app:get("/a-:bwa", function(req, res)
--   res:send("passed, bwa")
-- end)

-- app:get("/funny", function(req, res)
--   trace("zzz")
--   res:send("yawn")
-- end)

-- no work cuz escape
app:method("ANY", "(.*)", function(req, res)
  res:send("404")
end)

app:start({
  port = 8000,
  
  onstart = function(server, ip, port)
    print(("running on http://%s:%d"):format(ip, port))
  end
})

---  cahnge this to use ARGS (arg 1 is the start;scriptname, arg 0 is the exec)
--to enable debugging, use env DBG=1 in cli


--- TODO
--- fix 404
--- do fsrouter
--- do ftml
--- 
--- make this work on windows?