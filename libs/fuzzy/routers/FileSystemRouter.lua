local FS = require("fs")
local Path = require("path")

local Router = require("../Router")

local FTML = require("fuzzy.engines.FTML.FTML")

---@class fuzzy.routers.FileSystemRouter: fuzzy.Router
local FileSystemRouter = Router:extend()

---@alias fuzzy.routers.FileSystemRouter.Config {
---  directory: string,
---} | fuzzy.Router.Config

---@param config fuzzy.routers.FileSystemRouter.Config
function FileSystemRouter:initialize(config)
  self.ftml = FTML:new({
    directory = config.directory
  })

  Router.initialize(self, config --[[@as fuzzy.Router.Config]])

  -- local route_types = {
  --   "server.lua",
  --   "html", "html.lua",
  --   "css",
  --   "js"
  -- }

  local path = config.directory
  for i, filepath in pairs(FileSystemRouter:_recursive_file_readdir(path)) do
    local filename = Path.basename(filepath)
    local ext = string.match(filename, "%w+(%.[%w%.]+)")
    local filename_no_ext = Path.basename(filename, ext)

    local route_path = Path.dirname(Path.relative(path, filepath))
    if route_path == "." then route_path = "" end
    route_path = "/" .. route_path

    local chunk = FS.readFileSync(filepath)
    if chunk == nil then goto continue end

    if filename_no_ext == "+page" then
      if ext == ".html.lua" then
      elseif ext == ".html" then
        local parsed_chunk = self.ftml:parse(chunk)
        self:method("ANY", route_path, function(req, res)
          res:send(parsed_chunk, "text/html; charset=utf-8")
        end)
      elseif ext == ".js" then

      elseif ext == ".css" then
        
      end
    elseif filename_no_ext == "+server" then
    
    end

    ::continue::
  end
end

--- returns WITH path given (so if you pass "/dir/", you'll get {"/dir/help.txt", "/dir/1/2/3/meow.txt"})
function FileSystemRouter:_recursive_file_readdir(path)
  local files = {}
  
  for filename, filetype in FS.scandirSync(path) do
    local full_path = Path.join(path, filename)
    if filetype == "directory" then
      for _, f1 in pairs(self:_recursive_file_readdir(full_path)) do
        table.insert(files, f1)
      end
    elseif filetype == "file" then
      table.insert(files, full_path)
    end
  end

  return files
end

function FileSystemRouter:mount(router)
  error("fuzzy.routers.FileSystemRouter does not support mounting routers.")
end

return FileSystemRouter