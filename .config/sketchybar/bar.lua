local colors = require("colors")

-- Layout follows barik's own constants (`Barik/Constants.swift`:
-- menuBarHeight = 55, menuBarHorizontalPadding = 25). barik itself exposes
-- the height as a setting (`default`, `menu-bar`, or a float), and 55pt is
-- taller than this bar needs, so it runs a little shorter while keeping the
-- widget row centred and the same 25pt side padding.
--
-- The native menu bar is hidden outright by `utilities/menu_bar.sh`, and
-- `settings/aerospace.toml` reserves this height so tiled windows clear it.
-- Changing BAR_HEIGHT means changing that outer top gap to match.
local BAR_HEIGHT = 40
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
