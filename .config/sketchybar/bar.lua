local colors = require("colors")

-- barik's own layout constants (`Barik/Constants.swift`):
--   menuBarHeight = 55, menuBarHorizontalPadding = 25
-- The bar is deliberately taller than the notch strip, the widget row sits
-- centred inside it, which is what gives barik its airy look. The native menu
-- bar is hidden outright by `utilities/menu_bar.sh`, and
-- `settings/aerospace.toml` reserves this same height so tiled windows clear
-- it.
local BAR_HEIGHT = 55
local HORIZONTAL_PADDING = 25

sbar.bar({
  height = BAR_HEIGHT,
  color = colors.bar.bg,
  display = "all",
  topmost = "window",
  sticky = true,
  padding_left = HORIZONTAL_PADDING,
  padding_right = HORIZONTAL_PADDING,
  corner_radius = 0,
  border_width = 0,
  y_offset = 0,
  blur_radius = colors.theme == "light" and 30 or 0,
})
