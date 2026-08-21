local colors = require("colors")

-- Layout follows barik's own constants (`Barik/Constants.swift`:
-- menuBarHeight = 55, menuBarHorizontalPadding = 25), with the height brought
-- down to the real macOS menu bar height so the bar sits exactly where the
-- system one did. On a notched Mac that is the display's safe area inset,
-- which is 32pt here, so the bar fills the notch strip precisely.
--
-- The dark theme is deliberately solid black rather than translucent like
-- the system bar: at exactly the notch strip's height, an opaque black bar
-- makes the notch disappear into it. The light theme keeps the translucent,
-- blurred treatment.
--
-- The native bar is hidden outright by `utilities/menu_bar.sh`, and
-- `settings/aerospace.toml` reserves this height so tiled windows clear it.
-- Changing BAR_HEIGHT means changing that gap too.
local BAR_HEIGHT = 32
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
