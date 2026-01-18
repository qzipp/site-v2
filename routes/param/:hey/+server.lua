---@type fuzzy.FileSystemRouter.Exports
local exports = {}

exports.trailing = false

function exports:GET(req, res)
  res:send("get")
end
function exports:POST(req, res)
  res:send("post")
end
function exports:DELETE(req, res)
  res:send("delete")
end

return exports