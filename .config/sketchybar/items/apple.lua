local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Padding item required because of the bracket below.
sbar.add("item", { position = "left", width = settings.group_paddings })

local apple = sbar.add("item", {
  position = "left",
  icon = {
    font = { size = 15.0 },
    string = icons.apple,
    padding_left = 8,
    padding_right = 8,
  },
  label = { drawing = false },
  background = { color = colors.pill.bg, border_color = colors.pill.border, border_width = 1 },
  padding_left = 1,
  padding_right = 1,
  -- Real Apple menu, opened via the Accessibility API against the
  -- frontmost app's menu bar (index 0 is always the Apple menu).
  click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

sbar.add("bracket", "apple.bracket", { apple.name }, {
  background = { color = colors.transparent },
})

sbar.add("item", { position = "left", width = settings.group_paddings })
