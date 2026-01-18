--- qzip's utilities
-- mostly for string, table, and whatnot 

local libqu = {
  string = {},
  table = {}
}

function libqu.table.keys(t)
  local keys = {}
  for k, v in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end
function libqu.table.values(t)
  local values = {}
  for k, v in pairs(t) do
    table.insert(values, v)
  end
  return values
end


---@param s string
---@param separator string
---@return any ...
function libqu.string.split(s, separator)
  local arr = {}
  for v in string.gmatch(s, ("[^%s]+"):format(separator or "%s")) do
    table.insert(arr, v)
  end

  return table.unpack(arr)
end

function libqu.string.url_decode(url)
  return string.gsub(url, "%%(%x%x)", function(x)
    return string.char(tonumber(x, 16))
  end)
end
function libqu.string.url_encode(url)
  return string.gsub(url, "(.)", function(x)
    local byte = string.byte(x)
    return ("%%%x"):format(byte)
  end)
end

libqu.string.escape_symbols = {
  ["<"] = "&lt;",
  [">"] = "&gt;",
  ["&"] = "&amp;",
  ["\""] = "&quote;",
  ["'"] = "&apos;",
}

---escapes a string (by default escapes Lua's magic characters)
---@param str string
---@param method? "magic"|"html"
function libqu.string.escape(str, method)
  method = method or "magic"
  if method == "magic" then
    local new_str = string.gsub(str, "([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    return new_str
  elseif method == "html" then
    -- we get the keys. duh
    local escape_symbols_keys = libqu.table.keys(libqu.string.escape_symbols)
    local symbols_str = table.concat(escape_symbols_keys, "")

    local new_str = string.gsub(str, "(["..symbols_str.."])", function(symbol)
      local replacement = libqu.string.escape_symbols[symbol]
      
      return replacement
    end)
    return new_str
  else
    error("invalid method for escaping")
  end
end

return libqu