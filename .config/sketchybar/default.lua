local settings = require("settings")
local colors = require("colors")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 15.0,
    },
    color = colors.icon,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 13.0,
    },
    color = colors.text,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    height = 24,
    corner_radius = 12,
    color = colors.transparent,
    border_color = colors.transparent,
    border_width = 0,
  },
  popup = {
    background = {
      border_width = 1,
      -- barik's popup card: `.cornerRadius(40)` with `.shadow(radius: 30)`
      -- over a `Color.black` fill (`MenuBarPopupView`).
      corner_radius = 40,
      border_color = colors.popup.border,
      color = colors.popup.bg,
      shadow = { drawing = true },
    },
    blur_radius = 40,
    -- barik offsets its popup below the bar by 5pt
    -- (`.padding(.top, foregroundHeight + 5)`).
    y_offset = 5,
  },
  padding_left = 4,
  padding_right = 4,
  scroll_texts = true,
})
