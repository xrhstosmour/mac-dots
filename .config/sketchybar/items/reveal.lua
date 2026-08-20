local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Hidden by default (this bar covers the real menu bar entirely). Clicking
-- briefly hides this bar so the real menu bar -- and any third-party app menu
-- extras normally living there -- becomes visible again for a few seconds.
local REVEAL_SECONDS = 6

local reveal = sbar.add("item", "reveal", {
  position = "right",
  icon = { drawing = false },
  label = { string = icons.reveal, color = colors.subtext },
  background = { color = colors.transparent },
  padding_left = 4,
  padding_right = 4,
})

sbar.add("item", { position = "right", width = settings.group_paddings })

reveal:subscribe("mouse.clicked", function()
  sbar.bar({ drawing = false })
  sbar.delay(REVEAL_SECONDS, function()
    sbar.bar({ drawing = true })
  end)
end)
