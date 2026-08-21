local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local shell = require("helpers.shell")

local popup_width = 240
local last_nonzero_volume = 75

local mic_icon = sbar.add("item", "microphone.icon", {
  position = "right",
  icon = { string = icons.mic.on, color = colors.icon },
  label = { drawing = false },
  padding_left = 1,
  padding_right = 1,
  update_freq = 10,
})

local microphone_bracket = sbar.add("bracket", "microphone.bracket", { mic_icon.name }, {
  background = { color = colors.transparent },
  popup = { align = "left" },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local popup_position = "popup." .. microphone_bracket.name

-- A static row keeps the popup host alive even before any device row is
-- added, and makes the mute toggle discoverable instead of hiding it behind
-- a right click on the bar.
local status_row = sbar.add("item", "microphone.status", {
  position = popup_position,
  width = popup_width,
  align = "left",
  padding_left = 14,
  padding_right = 14,
  label = { string = "Microphone: On" },
})

local function refresh()
  sbar.exec('osascript -e "input volume of (get volume settings)"', function(volume)
    volume = tonumber(volume) or 0
    if volume > 0 then last_nonzero_volume = volume end
    mic_icon:set({ icon = (volume > 0) and icons.mic.on or icons.mic.off })
    status_row:set({ label = "Microphone: " .. ((volume > 0) and "On" or "Muted") })
  end)
end

local function toggle_mute()
  sbar.exec('osascript -e "input volume of (get volume settings)"', function(volume)
    volume = tonumber(volume) or 0
    local target = (volume > 0) and 0 or last_nonzero_volume
    sbar.exec('osascript -e "set volume input volume ' .. target .. '"', refresh)
  end)
end

local function hide_devices()
  microphone_bracket:set({ popup = { drawing = false } })
  sbar.remove("/microphone.device\\..*/")
end

local function show_input_devices()
  sbar.exec("SwitchAudioSource -t input -c", function(current_device)
    current_device = (current_device or ""):gsub("%s*$", "")
    sbar.exec("SwitchAudioSource -a -t input", function(available)
      local index = 0
      for device in string.gmatch(available or "", "[^\r\n]+") do
        local color = (device == current_device) and colors.text or colors.subtext
        sbar.add("item", "microphone.device." .. index, {
          position = popup_position,
          width = popup_width,
          align = "left",
  padding_left = 14,
  padding_right = 14,
          label = { string = device, color = color },
          click_script = "SwitchAudioSource -t input -s " .. shell.quote(device),
        })
        index = index + 1
      end
      microphone_bracket:set({ popup = { drawing = true } })
    end)
  end)
end

mic_icon:subscribe({ "routine", "forced", "system_woke" }, refresh)

mic_icon:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    toggle_mute()
    return
  end
  if microphone_bracket:query().popup.drawing == "off" then
    refresh()
    show_input_devices()
  else
    hide_devices()
  end
end)
mic_icon:subscribe("mouse.exited.global", hide_devices)

status_row:subscribe("mouse.clicked", toggle_mute)

refresh()
