local colors = require("colors")
local settings = require("settings")

local popup_width = 240

-- The percentage renders inside a battery-shaped outline (a rounded
-- rect plus a small nub), rather than a separate icon glyph next to the
-- number, matching barik's own battery look.
local battery = sbar.add("item", "battery", {
  position = "right",
  icon = { drawing = false },
  label = {
    string = "?%",
    font = { family = settings.font.numbers, size = 10.0 },
    color = colors.subtext,
    align = "center",
    width = 28,
    padding_left = 0,
    padding_right = 0,
  },
  background = {
    color = colors.transparent,
    border_color = colors.subtext,
    border_width = 1.3,
    height = 15,
    corner_radius = 4,
  },
  padding_left = 1,
  padding_right = 0,
})

local nub = sbar.add("item", "battery.nub", {
  position = "right",
  icon = { drawing = false },
  label = { drawing = false },
  background = {
    color = colors.subtext,
    height = 7,
    corner_radius = 1,
    -- `background.width` is not a property SketchyBar accepts. The nub is
    -- narrowed by padding the background inside the item's own width.
    padding_left = 1,
    padding_right = 1,
  },
  width = 4,
  padding_left = 0,
  padding_right = 1,
})

local battery_bracket = sbar.add("bracket", "battery.bracket", { battery.name, nub.name }, {
  background = { color = colors.transparent },
  popup = { align = "center" },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

-- Popup children must hang off the same item whose `popup.drawing` is
-- toggled. Attaching them to the icon while drawing the bracket leaves
-- the popup permanently empty.
local popup_position = "popup." .. battery_bracket.name

local remaining_row = sbar.add("item", "battery.remaining", {
  position = popup_position,
  width = popup_width,
  align = "center",
  label = { string = "Time remaining: --:--" },
})

local lowpower_row = sbar.add("item", "battery.lowpower", {
  position = popup_position,
  width = popup_width,
  align = "center",
  label = { string = "Low Power Mode: Off" },
})

local function refresh()
  sbar.exec("pmset -g batt", function(batt_info)
    batt_info = batt_info or ""
    local charge = tonumber((batt_info:match("(%d+)%%")))
    local charging = batt_info:find("AC Power") ~= nil

    local color = colors.subtext
    if charging then
      color = colors.green
    elseif charge then
      if charge <= 10 then color = colors.red
      elseif charge <= 20 then color = colors.orange
      end
    end

    battery:set({
      label = { string = (charge or "?") .. "%", color = color },
      background = { border_color = color },
    })
    nub:set({ background = { color = color } })

    local remaining = batt_info:match("(%d+:%d+) remaining")
    remaining_row:set({ label = "Time remaining: " .. (remaining or "Calculating…") })
  end)

  sbar.exec("pmset -g | grep lowpowermode", function(mode_info)
    local enabled = (mode_info or ""):match("(%d+)")
    lowpower_row:set({ label = "Low Power Mode: " .. (enabled == "1" and "On" or "Off") })
  end)
end

local function hide_popup()
  battery_bracket:set({ popup = { drawing = false } })
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, refresh)

battery:subscribe("mouse.clicked", function()
  local should_draw = battery_bracket:query().popup.drawing == "off"
  if should_draw then
    battery_bracket:set({ popup = { drawing = true } })
    refresh()
  else
    hide_popup()
  end
end)
battery:subscribe("mouse.exited.global", hide_popup)

-- Toggling low power mode needs root, and a standing passwordless sudoers
-- rule is not worth it for a menu bar click, so this opens the setting
-- instead of flipping it.
lowpower_row:subscribe("mouse.clicked", function()
  hide_popup()
  sbar.exec("open x-apple.systempreferences:com.apple.Battery-Settings.extension")
end)

refresh()
