local colors = require("colors")
local icons = require("icons")

sbar.add("item", "divider", {
  position = "right",
  icon = { drawing = false },
  label = { string = icons.divider, color = colors.subtext },
  background = { drawing = false },
  padding_left = 4,
  padding_right = 4,
})
