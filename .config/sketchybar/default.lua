local settings = require("settings")
local colors = require("colors")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 14.0,
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
      -- Rounder than the bar's own pills, matching barik's own popup card
      -- (a much larger corner radius than its list rows).
      corner_radius = 24,
      border_color = colors.popup.border,
      color = colors.popup.bg,
      shadow = { drawing = true },
    },
    blur_radius = 40,
    -- A small gap below the bar rather than the popup touching it directly.
    y_offset = 4,
  },
  padding_left = 4,
  padding_right = 4,
  scroll_texts = true,
})
