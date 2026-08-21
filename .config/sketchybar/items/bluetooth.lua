local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 240
local max_rows = 8

local bluetooth_icon = sbar.add("item", "bluetooth.icon", {
  position = "right",
  -- SF Symbols has no Bluetooth glyph (see `icons.lua`), so this item pins
  -- its own icon font rather than inheriting the bar's default SF Pro.
  icon = { string = icons.bluetooth.on, color = colors.icon, font = { family = "FiraCode Nerd Font" } },
  label = { drawing = false },
  padding_left = 1,
  padding_right = 1,
})

local bluetooth_bracket = sbar.add("bracket", "bluetooth.bracket", { bluetooth_icon.name }, {
  background = { color = colors.transparent },
  popup = { align = "left" },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local popup_position = "popup." .. bluetooth_bracket.name

local power_row = sbar.add("item", "bluetooth.power", {
  position = popup_position,
  width = popup_width,
  align = "left",
  label = { string = "Bluetooth: On" },
})

local paired_header = sbar.add("item", "bluetooth.paired_header", {
  position = popup_position,
  width = popup_width,
  align = "left",
  label = { string = "My Devices", color = colors.subtext },
  drawing = false,
})

local paired_rows = {}
for index = 1, max_rows do
  paired_rows[index] = sbar.add("item", "bluetooth.paired." .. index, {
    position = popup_position,
    width = popup_width,
    align = "left",
    drawing = false,
  })
end

local nearby_header = sbar.add("item", "bluetooth.nearby_header", {
  position = popup_position,
  width = popup_width,
  align = "left",
  label = { string = "Discover New Devices", color = colors.subtext },
})

local nearby_rows = {}
for index = 1, max_rows do
  nearby_rows[index] = sbar.add("item", "bluetooth.nearby." .. index, {
    position = popup_position,
    width = popup_width,
    align = "left",
    drawing = false,
  })
end

local paired_cache = {}
local nearby_cache = {}

local function refresh_bar_icon()
  sbar.exec("blueutil -p", function(power)
    local on = (tonumber(power) == 1)
    bluetooth_icon:set({ icon = on and icons.bluetooth.on or icons.bluetooth.off })
  end)
end

local function refresh_paired()
  sbar.exec("blueutil -p", function(power)
    local on = (tonumber(power) == 1)
    power_row:set({ label = "Bluetooth: " .. (on and "On" or "Off") })
    if not on then
      paired_header:set({ drawing = false })
      for index = 1, max_rows do paired_rows[index]:set({ drawing = false }) end
      return
    end

    sbar.exec("blueutil --paired --format json 2>/dev/null", function(paired)
      paired_cache = (type(paired) == "table") and paired or {}
      paired_header:set({ drawing = (#paired_cache > 0) })
      for index = 1, max_rows do
        local device = paired_cache[index]
        if device then
          local status = device.connected and "Connected" or "Not Connected"
          local name = (type(device.name) == "string" and device.name ~= "") and device.name or device.address
          paired_rows[index]:set({
            drawing = true,
            label = { string = name .. "  ·  " .. status, color = device.connected and colors.text or colors.subtext },
            click_script = "blueutil " .. (device.connected and "--disconnect " or "--connect ") .. device.address,
          })
        else
          paired_rows[index]:set({ drawing = false })
        end
      end
    end)
  end)
end

local scanning = false
local function scan_nearby()
  if scanning then return end
  scanning = true
  nearby_header:set({ label = "Discover New Devices — scanning…" })
  sbar.exec("blueutil --inquiry 6 --format json 2>/dev/null", function(found)
    scanning = false
    nearby_header:set({ label = "Discover New Devices" })
    local paired_addresses = {}
    for _, device in ipairs(paired_cache) do paired_addresses[device.address] = true end

    nearby_cache = {}
    if type(found) == "table" then
      for _, device in ipairs(found) do
        if not paired_addresses[device.address] and #nearby_cache < max_rows then
          table.insert(nearby_cache, device)
        end
      end
    end

    for index = 1, max_rows do
      local device = nearby_cache[index]
      if device then
        local name = (type(device.name) == "string" and device.name ~= "") and device.name or device.address
        nearby_rows[index]:set({
          drawing = true,
          label = { string = name },
          click_script = "blueutil --pair " .. device.address .. " && blueutil --connect " .. device.address,
        })
      else
        nearby_rows[index]:set({ drawing = false })
      end
    end
  end)
end

local function hide_popup()
  bluetooth_bracket:set({ popup = { drawing = false } })
end

power_row:subscribe("mouse.clicked", function()
  sbar.exec("blueutil -p", function(power)
    local target = (tonumber(power) == 1) and 0 or 1
    sbar.exec("blueutil -p " .. target, function()
      refresh_bar_icon()
      refresh_paired()
    end)
  end)
end)

nearby_header:subscribe("mouse.clicked", scan_nearby)

bluetooth_icon:subscribe("mouse.clicked", function()
  local should_draw = bluetooth_bracket:query().popup.drawing == "off"
  if should_draw then
    refresh_paired()
    bluetooth_bracket:set({ popup = { drawing = true } })
    scan_nearby()
  else
    hide_popup()
  end
end)
bluetooth_icon:subscribe("mouse.exited.global", hide_popup)
bluetooth_icon:subscribe({ "routine", "system_woke" }, refresh_bar_icon)

refresh_bar_icon()
