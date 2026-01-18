local Logger = require("../Logger")
local Node = require("./Node")

-- Fuzzy Table Markup Language
-- (would of been LTML, Lua Table Markup Language, but thats too boring)
local Object = require("core").Object

---@class fuzzy.FTML: luvit.core.Object
local FTML = Object:extend()

---@alias fuzzy.FTML.Config {
---  directory: string,
---}

---@param config fuzzy.FTML.Config
function FTML:initialize(config)
  self.config = config
end


function FTML:parse(html)
  local root = Node:new("__root")
  local selector = root

  -- closing tags (like <@example />)
  for raw_tag in html:gmatch("(<@.->)") do
    local tag_name, raw_attr, closed_char = raw_tag:match("@(%w+)%s*(.-)%s?(/)>")
    if closed_char ~= "/" then goto continue end

    local attr = FTML._attr_parse(raw_attr)

    print(tag_name, attr)

    ::continue::
    
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
          local attr = FTML._attr_parse(raw_attr)
    
          node.attributes =  
          selector:add(node)
          
          selector = node
        end
      end
    
      ::continue::
    end
  end

  -- todo: <in attr="mrrp"> <me> </in> shit like this 
  -- goodluk

end

---@param str string
---@return table<string, any>
function FTML._attr_parse(str)
  local ESCAPE = "\\"
  local SETTER = "="
  local SPACE = "%s"

  local attr = {}

  -- state
  local tmp_attr_is_v = false
  local tmp_attr_k = ""
  local tmp_attr_v = ""
  local tmp_attr_v_quote = ""
  local tmp_attr_v_quote_hit = 0
  local tmp_prev = nil

  local function attr_set()
    attr[tmp_attr_k] = tmp_attr_v == "" and nil or tmp_attr_v
    tmp_attr_is_v = false
    tmp_attr_v_quote = ""
    tmp_attr_k = ""
    tmp_attr_v = ""
    tmp_attr_v_quote_hit = 0
    tmp_prev = nil
  end

  -- okay this is a mess
  -- lets go step by step

  -- get every one character
  for char in str:gmatch("(.)") do
    -- print(("q=%s p=%s c=%s"):format(tmp_attr_v_quote, tmp_prev, c))

    if char == SETTER then
      tmp_attr_is_v = true
      -- else if its a space and its not in quotes
    elseif char:match(SPACE) ~= nil and tmp_attr_v_quote == "" then
      attr_set()
    else
      -- value write mode
      if tmp_attr_is_v then
        -- if no known quote char, lets set it
        if tmp_attr_v_quote == "" and (char == "'" or char == '"') then
          tmp_attr_v_quote = char
        end

        if char == ESCAPE then goto continue end
        if char == tmp_attr_v_quote then
          -- we match our known quote with the current char, now lets see if its not escaped
          -- we ignore escaped because thats not what we care about
          if tmp_prev ~= ESCAPE then
            tmp_attr_v_quote_hit = tmp_attr_v_quote_hit + 1
            if tmp_attr_v_quote_hit == 2 then
              attr_set()
            end
            goto continue
          end
        end

        -- print("SETTING ", c)
        tmp_attr_v = tmp_attr_v .. char
      else
        -- we shouldnt write an escape into a key..
        -- this should be a error tho
        if char ~= ESCAPE then
          tmp_attr_k = tmp_attr_k .. char
        end
      end
    end

    ::continue::
    -- print("SET PREV")
    tmp_prev = char
  end

  return attr
end


return FTML