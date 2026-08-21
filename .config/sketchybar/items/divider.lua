local colors = require("colors")
local settings = require("settings")

-- barik draws its divider as a small rounded capsule, not a glyph:
--   Rectangle().fill(Color.active).frame(width: 2, height: 15)
--     .clipShape(Capsule())
-- so this is a bare item whose background *is* the capsule.
sbar.add("item", "divider", {
  position = "right",
  icon = { drawing = false },
  label = { drawing = false },
  width = 2,
  background = {
    drawing = true,
    color = colors.pill_hover.bg,
    height = 15,
    corner_radius = 1,
  },
})

sbar.add("item", { position = "right", width = settings.group_paddings })
