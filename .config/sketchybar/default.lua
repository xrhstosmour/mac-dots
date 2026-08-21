local settings = require("settings")
local colors = require("colors")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      -- Apple draws menu bar glyphs at a regular weight, semibold reads
      -- noticeably heavier than the system bar it replaces.
      style = settings.font.style_map["Regular"],
      size = 15.0,
    },
    color = colors.icon,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Regular"],
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
      -- barik uses `.cornerRadius(40)`, but its cards are always tall (25pt
      -- padding around a multi-row list). At these row heights a 40pt radius
      -- fully rounds a one-row popup into a lozenge, so this is the largest
      -- radius that still reads as a card at every popup size.
      corner_radius = 16,
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
