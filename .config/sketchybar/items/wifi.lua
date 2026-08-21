local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 240
local INTERFACE = "en0"

-- Icon-only in the bar (no SSID shown); the network name lives in the
-- popup instead, matching the rest of the bar's minimal collapsed look.
local wifi_icon = sbar.add("item", "wifi.icon", {
  position = "right",
  icon = { string = icons.wifi.disconnected, color = colors.icon },
  label = { drawing = false },
  padding_left = 1,
  padding_right = 1,
  -- SketchyBar's own `wifi_change` event has been non-functional since
  -- macOS Sonoma, so this polls rather than relying on it alone.
  update_freq = 15,
})

local wifi_bracket = sbar.add("bracket", "wifi.bracket", { wifi_icon.name }, {
  background = { color = colors.transparent },
  popup = { align = "left" },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local popup_position = "popup." .. wifi_bracket.name

local power_row = sbar.add("item", "wifi.power", {
  position = popup_position,
  width = popup_width,
  align = "left",
  label = { string = "Wi-Fi: On" },
})

local network_row = sbar.add("item", "wifi.network", {
  position = popup_position,
  width = popup_width,
  align = "left",
  label = { string = "Network: ???" },
})

local ip_row = sbar.add("item", "wifi.ip", {
  position = popup_position,
  width = popup_width,
  align = "left",
  label = { string = "IP: ???" },
})

local join_row = sbar.add("item", "wifi.join", {
  position = popup_position,
  width = popup_width,
  align = "left",
  label = { string = "Join Other Network…" },
})

local settings_row = sbar.add("item", "wifi.settings", {
  position = popup_position,
  width = popup_width,
  align = "left",
  label = { string = "Open Network Settings" },
})

local function refresh_bar()
  sbar.exec("networksetup -getairportpower " .. INTERFACE, function(power_info)
    local power_on = (power_info or ""):find("On") ~= nil
    if not power_on then
      wifi_icon:set({ icon = icons.wifi.disconnected })
      return
    end
    sbar.exec("ipconfig getifaddr " .. INTERFACE .. " 2>/dev/null", function(ip)
      local connected = (ip or ""):gsub("%s+$", "") ~= ""
      wifi_icon:set({ icon = connected and icons.wifi.connected or icons.wifi.disconnected })
    end)
  end)
end

local function hide_popup()
  wifi_bracket:set({ popup = { drawing = false } })
end

local function refresh_popup()
  sbar.exec("networksetup -getairportpower " .. INTERFACE, function(power_info)
    local power_on = (power_info or ""):find("On") ~= nil
    power_row:set({ label = "Wi-Fi: " .. (power_on and "On" or "Off") })
  end)
  sbar.exec("ipconfig getifaddr " .. INTERFACE .. " 2>/dev/null", function(ip)
    ip = (ip or ""):gsub("%s+$", "")
    ip_row:set({ label = "IP: " .. (ip ~= "" and ip or "Not Connected") })
    if ip == "" then
      network_row:set({ label = "Network: Not Connected" })
    else
      sbar.exec("networksetup -getairportnetwork " .. INTERFACE .. " | awk -F': ' '{print $2}'", function(ssid)
        -- macOS withholds the SSID from command line tools unless Location
        -- Services is granted, so fall back to the plain connected state
        -- rather than showing an empty name.
        ssid = (ssid or ""):gsub("%s+$", "")
        network_row:set({ label = "Network: " .. (ssid ~= "" and ssid or "Connected") })
      end)
    end
  end)
end

wifi_icon:subscribe({ "routine", "forced", "wifi_change", "system_woke" }, function()
  refresh_bar()
  -- Refreshed on the same tick so opening the popup never shows a stale
  -- network name or address.
  refresh_popup()
end)

wifi_icon:subscribe("mouse.clicked", function()
  local should_draw = wifi_bracket:query().popup.drawing == "off"
  if should_draw then
    refresh_popup()
    wifi_bracket:set({ popup = { drawing = true } })
  else
    hide_popup()
  end
end)
wifi_icon:subscribe("mouse.exited.global", hide_popup)

power_row:subscribe("mouse.clicked", function()
  sbar.exec("networksetup -getairportpower " .. INTERFACE, function(power_info)
    local target = (power_info or ""):find("On") and "off" or "on"
    sbar.exec("networksetup -setairportpower " .. INTERFACE .. " " .. target, function()
      refresh_bar()
      refresh_popup()
    end)
  end)
end)

-- A single AppleScript invocation prompts for both fields and shells out
-- itself via `quoted form of`, so the SSID/password never get re-interpolated
-- into a second Lua-built command string (which would risk injection if
-- either contained a quote character).
local JOIN_SCRIPT = [[
osascript -e '
try
  set theSSID to text returned of (display dialog "Network name (SSID):" default answer "" with title "Join Wi-Fi Network")
  set thePassword to text returned of (display dialog ("Password for \"" & theSSID & "\":") default answer "" with title "Join Wi-Fi Network" with hidden answer)
  do shell script "networksetup -setairportnetwork ]] .. INTERFACE .. [[ " & quoted form of theSSID & " " & quoted form of thePassword
end try
'
]]

join_row:subscribe("mouse.clicked", function()
  hide_popup()
  sbar.exec(JOIN_SCRIPT, refresh_bar)
end)

settings_row:subscribe("mouse.clicked", function()
  hide_popup()
  sbar.exec("open x-apple.systempreferences:com.apple.Network-Settings.extension")
end)

refresh_bar()
