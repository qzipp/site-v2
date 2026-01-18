local PrettyPrint = require("pretty-print")
local Object = require("core").Object

local html = [[
<@TEST1 test='hi'>hi</@TEST1>

<@IN>
absa <@CHILD>aaaaaaa</@CHILD>
</@IN>
]]

-- ---@class fuzzy.FTML.Node: luvit.core.Object
-- local Node = Object:extend()

-- ---@param name string
-- function Node:initialize(name)
--   ---@type (fuzzy.FTML.Node|string)[]
--   self.children = {}

--   ---@type fuzzy.FTML.Node[]
--   self.nodes = setmetatable(self.children, {
--     __index = function(t, k)
--       return rawget(t, k)
--     end,
--     __newindex = function(t, k, v)
--       rawset(t, k, v)
--     end
--   })

--   if not name or name == "" then error("name is empty") end
--   if type(name) ~= "string" then error("name is not a string") end
--   self.name = name

--   ---@type fuzzy.FTML.Node
--   self.parent = nil
-- end

-- ---@param condition string|fun(node: string|fuzzy.FTML.Node): boolean
-- ---@param recursive boolean?
-- function Node:find(condition, recursive)
--   for i, node in pairs(self.children) do
--     if type(condition) == "function" then
--       if condition(node) then
--         return node
--       end
--     else
--       if node.name == condition then
--         return node
--       end
--     end
--   end
-- end

-- ---@param condition string|fun(node: string|fuzzy.FTML.Node): boolean
-- function Node:exists(condition)
--   return self:find(condition) ~= nil
-- end


-- ---@param node string|fuzzy.FTML.Node
-- function Node:add(node)
--   if type(node) == "table" then
--     node.parent = self
--   end

--   table.insert(self.children, node)

--   return node
-- end

local root = Node:new("__root")
local selector = root

for raw, closed_char, tag, content in html:gmatch("((/?)(@.-)>([^<]*)<)") do
  -- print("raw {", raw, "}", "closed_char {", closed_char, "}", "name {", name, "}", "content {", content ,"}")
  
  local name, raw_attr = tag:match("([@%w_%-]+)%s*(.*)")

  if closed_char == "/" then
    local node = selector.parent:find(name)

    if not node then error("end tag with no start tag") end

    selector = node.parent
  else
    if selector then
      local node = Node:new(name)
      node:add(content)

      selector:add(node)
      
      selector = node
    end
  end


  ::continue::
end

-- html:gsub("")

print(PrettyPrint.dump(root.nodes))
