local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local shell = require("helpers.shell")

local popup_width = 240

-- `media_change` is a built-in SketchyBar event (deprecated on macOS 26), so
-- the bridge in `helpers/media_watch/media_watch.sh` fires its own name
-- rather than colliding with it.
sbar.add("event", "now_playing_change")

-- Collapsed bar state is icon-only (no percentage), matching the rest of
-- the bar's minimal look; the percentage, device list, and now-playing
-- controls all live in the popup instead.
local volume_icon = sbar.add("item", "sound.icon", {
  position = "right",
  icon = { string = icons.volume._100, color = colors.icon },
  label = { drawing = false },
  padding_left = 1,
  padding_right = 1,
})

local sound_bracket = sbar.add("bracket", "sound.bracket", { volume_icon.name }, {
  background = { color = colors.transparent },
  popup = { align = "left" },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

-- Popup children must hang off the same item whose `popup.drawing` is
-- toggled. Attaching them to the icon while drawing the bracket leaves
-- the popup permanently empty.
local popup_position = "popup." .. sound_bracket.name

-- Now playing, folded into this same popup rather than its own bar icon.
local nowplaying_label = sbar.add("item", "sound.nowplaying", {
  position = popup_position,
  width = popup_width,
  align = "left",
  label = { string = "Nothing playing", max_chars = 26 },
})

-- One row, not three. SketchyBar lays out everything at a single "popup.X"
-- position as a single vertical (or, with `popup.horizontal`, single
-- horizontal) list, there's no per-row grouping, so three separate icon
-- items here would stack as three near-empty rows rather than sit side by
-- side (confirmed empirically). The three glyphs are concatenated into one
-- label instead, the same trick `items/calendar.lua` already uses for its
-- `‹ month ›` header. Left click toggles play/pause, matching the bar icon's
-- own primary click; right click skips to the next track; scrolling steps
-- back/forward, mirroring the volume icon's own scroll-to-adjust gesture.
local controls_row = sbar.add("item", "sound.controls", {
  position = popup_position,
  width = popup_width,
  align = "left",
  icon = { drawing = false },
  label = {
    string = icons.media.back .. "    " .. icons.media.play .. "    " .. icons.media.forward,
    font = { size = 18.0 },
  },
})

controls_row:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec("media-control next-track")
  else
    sbar.exec("media-control toggle-play-pause")
  end
end)
controls_row:subscribe("mouse.scrolled", function(env)
  sbar.exec("media-control " .. ((env.INFO.delta > 0) and "previous-track" or "next-track"))
end)

sbar.add("item", "sound.separator", {
  position = popup_position,
  width = popup_width,
  background = { height = 1, color = colors.pill.border },
})

local volume_percent_row = sbar.add("item", "sound.percent", {
  position = popup_position,
  width = popup_width,
  align = "left",
  label = { string = "Volume: ??%" },
})

local volume_slider = sbar.add("slider", popup_width, {
  position = popup_position,
  slider = {
    highlight_color = colors.blue,
    background = { height = 4, corner_radius = 2, color = colors.pill.bg },
    knob = { string = "●", drawing = true },
  },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

local function refresh_icon(volume)
  local icon = icons.volume._0
  if volume > 60 then
    icon = icons.volume._100
  elseif volume > 30 then
    icon = icons.volume._66
  elseif volume > 10 then
    icon = icons.volume._33
  elseif volume > 0 then
    icon = icons.volume._10
  end

  volume_icon:set({ icon = icon })
  volume_percent_row:set({ label = "Volume: " .. volume .. "%" })
  volume_slider:set({ slider = { percentage = volume } })
end

volume_icon:subscribe("volume_change", function(env)
  refresh_icon(tonumber(env.INFO))
end)

local function refresh_nowplaying()
  sbar.exec("media-control get --no-artwork 2>/dev/null", function(info)
    if type(info) ~= "table" then
      nowplaying_label:set({ label = "Nothing playing" })
      controls_row:set({
        label = { string = icons.media.back .. "    " .. icons.media.play .. "    " .. icons.media.forward },
      })
      return
    end

    local title = info.title or "Nothing playing"
    local artist = info.artist
    local label = (artist and artist ~= "") and (title .. " — " .. artist) or title

    nowplaying_label:set({ label = label })
    controls_row:set({
      label = {
        string = icons.media.back .. "    "
          .. (info.playing and icons.media.pause or icons.media.play)
          .. "    " .. icons.media.forward,
      },
    })
  end)
end

volume_icon:subscribe("now_playing_change", refresh_nowplaying)

local function hide_popup()
  sound_bracket:set({ popup = { drawing = false } })
  sbar.remove("/sound.device\\..*/")
end

local function show_output_devices()
  sbar.exec("SwitchAudioSource -t output -c", function(current_device)
    current_device = (current_device or ""):gsub("%s*$", "")
    sbar.exec("SwitchAudioSource -a -t output", function(available)
      local index = 0
      for device in string.gmatch(available or "", "[^\r\n]+") do
        local color = (device == current_device) and colors.text or colors.subtext
        sbar.add("item", "sound.device." .. index, {
          position = popup_position,
          width = popup_width,
          align = "left",
          label = { string = device, color = color },
          click_script = "SwitchAudioSource -t output -s " .. shell.quote(device),
        })
        index = index + 1
      end
    end)
  end)
end

local function toggle_popup(env)
  if env.BUTTON == "right" then
    sbar.exec("open x-apple.systempreferences:com.apple.Sound-Settings.extension")
    return
  end
  local should_draw = sound_bracket:query().popup.drawing == "off"
  if should_draw then
    refresh_nowplaying()
    show_output_devices()
    sound_bracket:set({ popup = { drawing = true } })
  else
    hide_popup()
  end
end

local function scroll(env)
  local delta = env.INFO.delta
  if not (env.INFO.modifier == "ctrl") then delta = delta * 5.0 end
  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe("mouse.clicked", toggle_popup)
volume_icon:subscribe("mouse.scrolled", scroll)
volume_icon:subscribe("mouse.exited.global", hide_popup)

-- Start (or restart) the background bridge that fires `now_playing_change`.
sbar.exec("nohup $CONFIG_DIR/helpers/media_watch/media_watch.sh >/dev/null 2>&1 &")

sbar.exec('osascript -e "output volume of (get volume settings)"', function(volume)
  refresh_icon(tonumber(volume) or 0)
end)
