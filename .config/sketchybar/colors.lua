-- Follows System Settings -> Appearance automatically: dark mode gets the
-- solid black, notch-hiding bar, light mode gets the translucent bar.
-- Read once at startup/reload (synchronous is fine here, same as the
-- `make` call in helpers/init.lua, since this runs before the event loop).
local function detect_theme()
  local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  local style = handle and handle:read("*a") or ""
  if handle then handle:close() end
  return style:find("Dark") and "black" or "light"
end

local THEME = detect_theme()

local M = { theme = THEME }

M.white = 0xffffffff
M.black = 0xff000000
M.transparent = 0x00000000
M.red = 0xffff453a
M.orange = 0xffff9f0a
M.yellow = 0xffffd60a
M.green = 0xff32d74b
M.blue = 0xff0a84ff
M.grey = 0xff8e8e93

if THEME == "light" then
  M.bar = { bg = 0xe6f5f5f7 }
  M.pill = { bg = 0xffffffff, border = 0x14000000 }
  M.pill_hover = { bg = 0x0d000000 }
  M.text = 0xff1c1c1e
  M.subtext = 0xff6e6e73
  M.icon = 0xff1c1c1e
  M.popup = { bg = 0xfaf5f5f7, border = 0x1a000000 }
else
  M.bar = { bg = 0xff000000 }
  M.pill = { bg = 0x1affffff, border = 0x1effffff }
  M.pill_hover = { bg = 0x33ffffff }
  M.text = 0xffe5e5e7
  M.subtext = 0xff9a9a9e
  M.icon = 0xffe5e5e7
  M.popup = { bg = 0xf01c1c1e, border = 0x33ffffff }
end

-- The theme above is resolved once, at config time. macOS broadcasts a
-- distributed notification whenever Appearance changes, so reload the whole
-- config on it and every colour is re-derived from the new setting.
sbar.add("event", "appearance_change", "AppleInterfaceThemeChangedNotification")
sbar.add("item", "appearance.observer", { drawing = false, updates = true })
  :subscribe("appearance_change", function()
    sbar.exec("sketchybar --reload")
  end)

M.with_alpha = function(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then return color end
  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return M
