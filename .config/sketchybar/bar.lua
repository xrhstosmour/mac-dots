local colors = require("colors")

-- The native menu bar is hidden outright by `utilities/menu_bar.sh`, so this
-- bar stands in for it on every connected display. In the black theme it also
-- hides the notch.
--
-- Height comes from the display's own safe area inset, which on a notched Mac
-- is exactly the strip macOS keeps windows out of (32pt on this machine),
-- so the bar fills that strip precisely instead of eating window space below
-- it. Machines with no notch fall back to the same value, which is the height
-- `settings/aerospace.toml` reserves as its outer top gap on external
-- displays. Read synchronously because this runs before the event loop, the
-- same way `colors.lua` reads the system Appearance.
local DEFAULT_HEIGHT = 32

local function detect_height()
  local handle = io.popen([[osascript -l JavaScript -e '
    ObjC.import("AppKit");
    const screens = $.NSScreen.screens;
    let top = 0;
    for (let index = 0; index < screens.count; index++) {
      top = Math.max(top, screens.objectAtIndex(index).safeAreaInsets.top);
    }
    top' 2>/dev/null]])
  local value = handle and tonumber(handle:read("*a")) or nil
  if handle then handle:close() end
  if not value or value < DEFAULT_HEIGHT then return DEFAULT_HEIGHT end
  return math.floor(value)
end

sbar.bar({
  height = detect_height(),
  color = colors.bar.bg,
  display = "all",
  topmost = "window",
  sticky = true,
  padding_left = 0,
  padding_right = 0,
  corner_radius = 0,
  border_width = 0,
  y_offset = 0,
  blur_radius = colors.theme == "light" and 30 or 0,
})
