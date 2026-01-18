local Object = require("core").Object

---@class fuzzy.FTML.Node: luvit.core.Object
local Node = Object:extend()

---@param name string
function Node:initialize(name)
  ---@type (fuzzy.FTML.Node|string)[]
  self.children = {}

  ---@type fuzzy.FTML.Node[]
  self.nodes = setmetatable(self.children, {
    __index = function(t, k)
      return rawget(t, k)
    end,
    __newindex = function(t, k, v)
      rawset(t, k, v)
    end
  })

  if not name or name == "" then error("name is empty") end
  if type(name) ~= "string" then error("name is not a string") end
  self.name = name

  ---@type fuzzy.FTML.Node
  self.parent = nil
end

---@param condition string|fun(node: string|fuzzy.FTML.Node): boolean
---@param recursive boolean?
function Node:find(condition, recursive)
  for i, node in pairs(self.children) do
    if type(condition) == "function" then
      if condition(node) then
        return node
      end
    else
      if node.name == condition then
        return node
      end
    end
  end
end

---@param condition string|fun(node: string|fuzzy.FTML.Node): boolean
function Node:exists(condition)
  return self:find(condition) ~= nil
end


---@param node string|fuzzy.FTML.Node
function Node:add(node)
  if type(node) == "table" then
    node.parent = self
  end

  table.insert(self.children, node)

  return node
end

return Node