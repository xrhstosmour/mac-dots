local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- macOS shows microphone and camera use only in the native menu bar, which
-- this configuration hides, so the indicators are rebuilt here from the same
-- CoreAudio/CoreMediaIO properties the system watches. See
-- `helpers/indicators/indicators.c`, including its Bluetooth microphone caveat.
-- SketchyBar's argument parser treats any item name beginning with
-- `privacy.` exactly like `popup.`, so the obvious namespace for this widget
-- silently fails to build its bracket. Named after Omarchy's own widget
-- instead, which sidesteps it.
local PROBE = "$CONFIG_DIR/helpers/indicators/bin/indicators"

-- The same colours macOS itself uses for these two dots.
local microphone = sbar.add("item", "indicators.microphone", {
  position = "right",
  icon = { string = icons.mic.on, color = colors.orange },
  label = { drawing = false },
  padding_left = 1,
  padding_right = 1,
  drawing = false,
  update_freq = 3,
  -- `default.lua` sets `updates = "when_shown"` bar-wide, which also pauses
  -- `update_freq`-driven `routine` ticks while an item isn't drawn. This
  -- item's entire job is to stay hidden until it detects activity, so with
  -- the default it can never re-check itself into existence. Verified
  -- empirically: with `when_shown`, a live microphone never appears here.
  updates = "on",
})

local camera = sbar.add("item", "indicators.camera", {
  position = "right",
  icon = { string = icons.camera, color = colors.green },
  label = { drawing = false },
  padding_left = 1,
  padding_right = 1,
  drawing = false,
})

local indicators_bracket = sbar.add("bracket", "indicators.bracket", { microphone.name, camera.name }, {
  background = { color = colors.pill.bg, border_color = colors.pill.border, border_width = 1 },
  drawing = false,
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local function refresh()
  sbar.exec(PROBE, function(result)
    result = result or ""
    local microphone_active = result:match("microphone=(%d)") == "1"
    local camera_active = result:match("camera=(%d)") == "1"

    microphone:set({ drawing = microphone_active })
    camera:set({ drawing = camera_active })
    -- The whole pill disappears when nothing is in use, so the bar stays
    -- clean and the indicator is impossible to miss when it does appear.
    indicators_bracket:set({ drawing = microphone_active or camera_active })
  end)
end

microphone:subscribe({ "routine", "forced", "system_woke" }, refresh)

-- Both indicators open the same place macOS sends you from its own dot.
local function open_privacy_settings()
  sbar.exec("open x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension")
end

microphone:subscribe("mouse.clicked", open_privacy_settings)
camera:subscribe("mouse.clicked", open_privacy_settings)

refresh()
