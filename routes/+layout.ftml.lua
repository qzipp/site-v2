local FTML = require("./libs/FTML")

trace(locals.hi)

FTML.escape"bwa"

local el = function ()
  -- for ftml
end

return FTML.html {
  head() {
    title({ attr = "" }) { "hi" }
  },
  body() {
    CustomElement({
      class = "hi",
      onload = function() 
        trace("hewo world")
      end,
      onbload = "console.log(event)" -- or js instead
    }) {"hi"},

    div() {"hi"}, -- no attr table
    div({ class = "hi" }), -- no content/ftml table
    div({ class = "hi", html = "<h1>hi</h1>" }), -- html attr

    script() {
      function ()
        trace("bwa")
      end
    }
  }
}