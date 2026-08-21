local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- The status items apps pin to the native macOS menu bar (Amphetamine,
-- Maccy, Google Drive, DockDoor and friends). SketchyBar can mirror them as
-- `alias` items, which draw the real menu bar item and forward clicks to it,
-- and they keep rendering even though `utilities/menu_bar.sh` hides the
-- native bar.
--
-- They start hidden behind a chevron, the way macOS itself collapses overflow
-- items, so the bar stays clean until you ask for them.

-- Skipped because this bar already replaces them with its own widgets, so
-- aliasing them too would show everything twice. `BentoBox-0` is Control
-- Centre itself.
local REPLACED_BY_OWN_WIDGET = {
  ["Clock"] = true,
  ["Battery"] = true,
  ["WiFi"] = true,
  ["Bluetooth"] = true,
  ["Sound"] = true,
  ["BentoBox-0"] = true,
}

local chevron = sbar.add("item", "menu_extras.toggle", {
  position = "right",
  icon = { drawing = false },
  label = { string = icons.reveal, color = colors.subtext },
  background = { drawing = false },
  padding_left = 4,
  padding_right = 4,
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local aliases = {}
local expanded = false

local function set_expanded(value)
  expanded = value
  for _, name in ipairs(aliases) do
    sbar.set(name, { drawing = value })
  end
  -- Chevron points the way it will move: `›` to reveal, `‹` to collapse.
  chevron:set({ label = { string = value and icons.chevron_left or icons.reveal } })
end

-- `--query default_menu_items` lists every aliasable item as
-- "<owner>,<name>(<index>)". The index disambiguates the several items that
-- all report the generic name "Item-0", and is accepted verbatim by
-- `--add alias`.
--
-- The query has to wait until SketchyBar has finished building the rest of
-- the bar: asked during config load it answers with an empty string, since
-- it is still busy and cannot serve a query against itself yet. So this
-- retries on a delay until it gets a real answer.
local BUILD_RETRY_SECONDS = 2
local BUILD_MAX_ATTEMPTS = 10
local attempts = 0

local function build_aliases()
  attempts = attempts + 1
  sbar.exec("sketchybar --query default_menu_items", function(entries)
    if type(entries) ~= "table" then
      if attempts < BUILD_MAX_ATTEMPTS then
        sbar.delay(BUILD_RETRY_SECONDS, build_aliases)
      end
      return
    end

    for _, entry in ipairs(entries) do
      local without_index = entry:match("^(.*)%(%d+%)$") or entry
      local _, name = without_index:match("^(.-),(.*)$")

      if not REPLACED_BY_OWN_WIDGET[name] then
        sbar.add("alias", entry, {
          position = "right",
          drawing = false,
          padding_left = 2,
          padding_right = 2,
          background = { drawing = false },
          alias = { color = colors.icon },
        })
        table.insert(aliases, entry)
      end
    end
  end)
end

sbar.delay(BUILD_RETRY_SECONDS, build_aliases)

chevron:subscribe("mouse.clicked", function()
  set_expanded(not expanded)
end)
