local colors = require("colors")
local settings = require("settings")

-- Mirrors barik's own Spaces widget: one pill per workspace holding the
-- workspace key and the real icon of every window in it, with the focused
-- window marked and its title spelled out next to it.
local WORKSPACE_COUNT = 10
local MAX_WINDOWS = 6
local TITLE_MAX_LENGTH = 50

-- Every item is created once, in final order, and only ever toggled or
-- re-set afterwards. Adding and removing items on each refresh would append
-- them to the end of the left region (breaking the pill order) and make the
-- bar flicker on every workspace switch.
local numbers = {}
local icons = {}
local titles = {}
local overflows = {}

-- One shell invocation returns everything the widget needs: the focused
-- workspace, the focused window, and every window on every workspace.
-- Tab separated because window titles routinely contain punctuation, and
-- the tab comes from `printf` because AeroSpace's `--format` passes `\t`
-- through literally instead of expanding it.
local QUERY = table.concat({
  [[TAB=$(printf '\t')]],
  [[aerospace list-workspaces --focused | sed "s/^/W${TAB}/"]],
  [[aerospace list-windows --focused --format '%{window-id}' 2>/dev/null | sed "s/^/F${TAB}/"]],
  [[aerospace list-windows --all --format ]]
    .. [["%{workspace}${TAB}%{window-id}${TAB}%{app-bundle-id}${TAB}%{app-name}${TAB}%{window-title}" ]]
    .. [[| sed "s/^/L${TAB}/"]],
}, "; ")

sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "aerospace_focus_change")

sbar.add("item", { position = "left", width = settings.group_paddings })

for index = 1, WORKSPACE_COUNT do
  numbers[index] = sbar.add("item", "aerospace.workspace." .. index, {
    position = "left",
    icon = { drawing = false },
    label = {
      string = tostring(index),
      color = colors.subtext,
      font = { family = settings.font.numbers, style = settings.font.style_map["Semibold"] },
      padding_left = 9,
      padding_right = 5,
    },
    click_script = "aerospace workspace " .. index,
    drawing = false,
  })

  icons[index] = {}
  titles[index] = {}

  -- Icon and title slots alternate so the focused window's title lands
  -- directly after its own icon, the way barik lays it out.
  for slot = 1, MAX_WINDOWS do
    icons[index][slot] = sbar.add("item", "aerospace.window." .. index .. "." .. slot, {
      position = "left",
      icon = { drawing = false },
      label = { drawing = false },
      width = 26,
      padding_left = 1,
      padding_right = 1,
      background = {
        drawing = true,
        color = colors.transparent,
        corner_radius = 8,
        -- `clip` shapes the image to the background's own rounded rect,
        -- without it a large source icon overflows past the pill edges
        -- uncropped. `scale` is a raw multiplier on the source image's own
        -- pixel size, not a fit-to-frame fraction, 0.9 fills a 24pt row
        -- without the icon reading as oversized, verified empirically against
        -- a live render (SketchyBar's docs don't specify this).
        height = 24,
        clip = 1.0,
        image = { scale = 0.9, drawing = true },
      },
      drawing = false,
    })

    titles[index][slot] = sbar.add("item", "aerospace.title." .. index .. "." .. slot, {
      position = "left",
      icon = { drawing = false },
      label = { color = colors.text, padding_left = 2, padding_right = 6 },
      background = { drawing = false },
      drawing = false,
    })
  end

  -- Shown instead of a seventh icon when a workspace holds more windows
  -- than there are slots, so the pill never silently drops windows.
  overflows[index] = sbar.add("item", "aerospace.overflow." .. index, {
    position = "left",
    icon = { drawing = false },
    label = {
      color = colors.subtext,
      font = { family = settings.font.numbers },
      padding_left = 2,
      padding_right = 8,
    },
    background = { drawing = false },
    drawing = false,
  })

  local members = { numbers[index].name }
  for slot = 1, MAX_WINDOWS do
    table.insert(members, icons[index][slot].name)
    table.insert(members, titles[index][slot].name)
  end
  table.insert(members, overflows[index].name)

  sbar.add("bracket", "aerospace.bracket." .. index, members, {
    background = {
      color = colors.pill.bg,
      border_color = colors.pill.border,
      border_width = 1,
      corner_radius = 8,
      height = 26,
    },
    drawing = false,
  })
end

sbar.add("item", { position = "left", width = settings.group_paddings })

local function truncate(text)
  if #text <= TITLE_MAX_LENGTH then return text end
  return text:sub(1, TITLE_MAX_LENGTH) .. "..."
end

local previous_signature = ""

local function apply(workspaces, focused_workspace, focused_window)
  for index = 1, WORKSPACE_COUNT do
    local windows = workspaces[index] or {}
    local is_focused = (index == focused_workspace)
    local should_show = is_focused or #windows > 0

    -- How many windows of each app live here, mirroring barik's rule of
    -- showing the window title only when one app owns several windows.
    local app_counts = {}
    for _, window in ipairs(windows) do
      app_counts[window.app] = (app_counts[window.app] or 0) + 1
    end

    numbers[index]:set({
      drawing = should_show,
      label = { color = is_focused and colors.text or colors.subtext },
    })

    sbar.set("aerospace.bracket." .. index, {
      drawing = should_show,
      background = { color = is_focused and colors.pill_hover.bg or colors.pill.bg },
    })

    for slot = 1, MAX_WINDOWS do
      local window = windows[slot]
      if should_show and window then
        local is_window_focused = (window.id == focused_window)
        icons[index][slot]:set({
          drawing = true,
          background = {
            -- SketchyBar cannot vary a background image's opacity, so the
            -- focused window is marked with barik's `selected` background
            -- instead of dimming the others.
            color = is_window_focused and colors.pill_hover.bg or colors.transparent,
            image = { string = "app." .. window.bundle_id, drawing = true },
          },
        })

        local title = window.title
        if (app_counts[window.app] or 0) <= 1 or title == "" then title = window.app end
        titles[index][slot]:set({
          drawing = is_window_focused and title ~= "",
          label = { string = truncate(title) },
        })
      else
        icons[index][slot]:set({ drawing = false })
        titles[index][slot]:set({ drawing = false })
      end
    end

    local hidden = #windows - MAX_WINDOWS
    overflows[index]:set({
      drawing = should_show and hidden > 0,
      label = { string = "+" .. math.max(hidden, 0) },
    })
  end
end

local function refresh()
  sbar.exec(QUERY, function(result)
    local workspaces = {}
    local focused_workspace, focused_window

    for line in (result or ""):gmatch("[^\r\n]+") do
      local kind, rest = line:match("^(%a)\t(.*)$")
      if kind == "W" then
        focused_workspace = tonumber(rest)
      elseif kind == "F" then
        focused_window = rest
      elseif kind == "L" then
        -- Everything after the fourth tab is the window title, which is
        -- free to contain tabs of its own.
        local workspace, id, bundle_id, app, title =
          rest:match("^([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t(.*)$")
        local key = tonumber(workspace)
        if key then
          workspaces[key] = workspaces[key] or {}
          table.insert(workspaces[key], {
            id = id,
            bundle_id = bundle_id,
            app = app,
            title = title,
          })
        end
      end
    end

    -- Nothing visible changed, so leave every item untouched rather than
    -- re-setting the whole bar on each tick.
    local signature = (result or "")
    if signature == previous_signature then return end
    previous_signature = signature

    sbar.animate("sin", 10, function()
      apply(workspaces, focused_workspace, focused_window)
    end)
  end)
end

-- Wired from `exec-on-workspace-change`/`on-focus-changed` in
-- `settings/aerospace.toml`. `front_app_switched` catches focus moves
-- AeroSpace does not report, and the timer is only a safety net for
-- windows opening or closing without any focus change at all.
sbar.add("item", "aerospace.observer", { drawing = false, updates = true })
  :subscribe({
    "aerospace_workspace_change",
    "aerospace_focus_change",
    "front_app_switched",
    "forced",
  }, refresh)

local function periodic_refresh()
  refresh()
  sbar.delay(10, periodic_refresh)
end

periodic_refresh()
