local colors = require("colors")
local settings = require("settings")

-- SketchyBar popups are a single stack of items, so the month grid is drawn
-- as six monospaced rows rather than 42 individual cells (which would stack
-- vertically into a column ~50 rows tall).
local popup_width = 232
local weekday_labels = { "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su" }

local calendar = sbar.add("item", "calendar", {
  position = "right",
  icon = { drawing = false },
  label = {
    string = os.date("%a %d, %H:%M"),
    font = { family = settings.font.numbers },
    color = colors.text,
  },
  padding_left = 1,
  padding_right = 1,
  update_freq = 30,
})

local calendar_bracket = sbar.add("bracket", "calendar.bracket", { calendar.name }, {
  background = { color = colors.transparent },
  popup = { align = "right" },
})

local popup_position = "popup." .. calendar_bracket.name

local function popup_row(name, properties)
  local defaults = {
    position = popup_position,
    width = popup_width,
    padding_left = 14,
    padding_right = 14,
    icon = { drawing = false },
    label = {
      font = { family = settings.font.numbers },
      align = "center",
      width = popup_width - 20,
    },
  }
  for key, value in pairs(properties or {}) do defaults[key] = value end
  return sbar.add("item", name, defaults)
end

-- Left click steps forward a month, right click steps back, matching the
-- chevrons drawn in the label itself.
local month_header = popup_row("calendar.month", {
  label = {
    string = "",
    font = { family = settings.font.numbers, style = settings.font.style_map["Bold"] },
    align = "center",
  padding_left = 14,
  padding_right = 14,
    width = popup_width - 20,
  },
})

popup_row("calendar.weekdays", {
  label = {
    string = table.concat(weekday_labels, "  "),
    color = colors.subtext,
    font = { family = settings.font.numbers },
    align = "center",
  padding_left = 14,
  padding_right = 14,
    width = popup_width - 20,
  },
})

local week_rows = {}
for index = 1, 6 do
  week_rows[index] = popup_row("calendar.week." .. index, {})
end

local open_row = popup_row("calendar.open", {
  label = {
    string = "Open Calendar",
    color = colors.subtext,
    font = { family = settings.font.text },
    align = "center",
  padding_left = 14,
  padding_right = 14,
    width = popup_width - 20,
  },
})

local month_names = {
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
}

local today = os.date("*t")
local view_year, view_month = today.year, today.month

local function days_in_month(year, month)
  return tonumber(os.date("%d", os.time({ year = year, month = month + 1, day = 0, hour = 12 })))
end

-- Monday-first column index (0 = Monday .. 6 = Sunday) for the 1st of the month.
local function first_column(year, month)
  local weekday = tonumber(os.date("%w", os.time({ year = year, month = month, day = 1, hour = 12 })))
  return (weekday + 6) % 7
end

-- Every cell is exactly four characters wide so the columns line up, and
-- today is bracketed rather than coloured (a row is a single label, so it
-- cannot carry a per-day colour).
local function cell(day_number, is_today)
  if not day_number then return "    " end
  if is_today then return string.format("[%2d]", day_number) end
  return string.format(" %2d ", day_number)
end

local function render_month()
  month_header:set({ label = "‹   " .. month_names[view_month] .. " " .. view_year .. "   ›" })

  local leading = first_column(view_year, view_month)
  local total_days = days_in_month(view_year, view_month)
  local is_current_month = (view_year == today.year and view_month == today.month)

  for row = 1, 6 do
    local cells = {}
    for column = 1, 7 do
      local index = (row - 1) * 7 + column
      local day_number = index - leading
      if day_number < 1 or day_number > total_days then day_number = nil end
      table.insert(cells, cell(day_number, is_current_month and day_number == today.day))
    end
    week_rows[row]:set({ label = table.concat(cells) })
  end
end

local function step_month(offset)
  view_month = view_month + offset
  if view_month == 0 then view_month = 12; view_year = view_year - 1 end
  if view_month == 13 then view_month = 1; view_year = view_year + 1 end
  render_month()
end

month_header:subscribe("mouse.clicked", function(env)
  step_month(env.BUTTON == "right" and -1 or 1)
end)

local function hide_popup()
  calendar_bracket:set({ popup = { drawing = false } })
end

calendar:subscribe({ "routine", "forced", "system_woke" }, function()
  calendar:set({ label = os.date("%a %d, %H:%M") })
  today = os.date("*t")
end)

-- Left click toggles the month grid, matching every other widget in the bar.
-- Right click, or the row at the bottom of the popup, opens the real Calendar
-- app (which shows both local and Google events once a Google account is
-- added under System Settings -> Internet Accounts).
calendar:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec("open -a Calendar")
    hide_popup()
    return
  end

  local should_draw = calendar_bracket:query().popup.drawing == "off"
  if should_draw then
    view_year, view_month = today.year, today.month
    render_month()
    calendar_bracket:set({ popup = { drawing = true } })
  else
    hide_popup()
  end
end)
calendar:subscribe("mouse.exited.global", hide_popup)

open_row:subscribe("mouse.clicked", function()
  sbar.exec("open -a Calendar")
  hide_popup()
end)

render_month()
