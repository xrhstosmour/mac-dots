local colors = require("colors")
local settings = require("settings")

local READ_CURRENT = "defaults read com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null"

-- Converting the whole `HIToolbox` domain to JSON fails ("Invalid object in
-- plist for JSON format") because of unrelated keys elsewhere in it, so
-- extract just this one key as its own plist first, then convert that.
local READ_ENABLED = "defaults export com.apple.HIToolbox.plist - "
  .. "| plutil -extract AppleEnabledInputSources xml1 -o - - "
  .. "| plutil -convert json -o - -"

sbar.add("event", "input_source_change", "AppleSelectedInputSourcesChangedNotification")

local language = sbar.add("item", "language", {
  position = "right",
  icon = { drawing = false },
  label = { string = "?", font = { family = settings.font.numbers }, color = colors.text },
  padding_left = 1,
  padding_right = 1,
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local popup_position = "popup." .. language.name

-- Populated from the enabled sources themselves, no manual list to maintain.
local known_sources = {}

-- Keyboard layout IDs follow `com.apple.keylayout.<Name>` with spaces/periods
-- stripped from the display name (e.g. "U.S." -> "US"). Holds for the
-- overwhelming majority of layouts; the Control-Space cycle below always
-- works regardless of this, so an occasional mismatch here is harmless.
local function layout_id(name)
  return "com.apple.keylayout." .. (name or ""):gsub("[%s%.]", "")
end

local function short_label(source_id)
  return known_sources[source_id] or (source_id or "?"):match("[^.]+$") or "?"
end

local function populate_sources()
  sbar.exec(READ_ENABLED, function(sources)
    if type(sources) ~= "table" then return end

    for _, source in ipairs(sources) do
      local kind = source["InputSourceKind"]
      local id, label

      if kind == "Keyboard Layout" then
        label = source["KeyboardLayout Name"]
        id = label and layout_id(label)
      elseif kind == "Input Method" and source["Input Mode"] then
        id = source["Input Mode"]
        label = id:match("[^.]+$")
      end
      -- Anything else (e.g. "Non Keyboard Input Method" -- Character
      -- Viewer, Emoji & Symbols) isn't a language to switch to, skip it.

      if id and label then
        known_sources[id] = label
        sbar.add("item", "language.source." .. id, {
          position = popup_position,
          width = 200,
          align = "left",
  padding_left = 14,
  padding_right = 14,
          label = { string = label },
          click_script = "macism " .. id,
        })
      end
    end
  end)
end

local function refresh()
  sbar.exec(READ_CURRENT, function(result)
    language:set({ label = short_label((result or ""):gsub("%s+$", "")) })
  end)
end

language:subscribe("input_source_change", refresh)

language:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    language:set({ popup = { drawing = "toggle" } })
    return
  end
  -- Cycles to the next enabled source, the same shortcut macOS itself uses
  -- (Control-Space), so it always works even for sources not listed above.
  sbar.exec('osascript -e \'tell application "System Events" to key code 49 using control down\'')
end)
language:subscribe("mouse.exited.global", function()
  language:set({ popup = { drawing = false } })
end)

populate_sources()
refresh()
