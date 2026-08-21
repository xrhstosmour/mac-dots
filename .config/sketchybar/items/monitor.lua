local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 260
local process_rows_count = 5

-- One shell invocation for both readings. `top -l 1 -n 0` reports the CPU
-- split without listing any processes, and `memory_pressure` reports free
-- memory as a percentage, which is the only figure that does not need the
-- machine's total RAM to interpret.
local QUERY = "top -l 1 -n 0 | grep '^CPU usage'; memory_pressure | grep 'free percentage'"
local PROCESS_QUERY = "ps -Aceo pcpu,comm -r | head -n " .. (process_rows_count + 1)

local cpu = sbar.add("item", "monitor.cpu", {
  position = "right",
  icon = { string = icons.cpu, color = colors.icon },
  label = { string = "--%", font = { family = settings.font.numbers }, color = colors.text },
  padding_left = 1,
  padding_right = 1,
  update_freq = 5,
})

local memory = sbar.add("item", "monitor.memory", {
  position = "right",
  icon = { string = icons.memory, color = colors.icon },
  label = { string = "--%", font = { family = settings.font.numbers }, color = colors.text },
  padding_left = 1,
  padding_right = 1,
})

local monitor_bracket = sbar.add("bracket", "monitor.bracket", { cpu.name, memory.name }, {
  popup = { align = "left" },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local popup_position = "popup." .. monitor_bracket.name

local header_row = sbar.add("item", "monitor.header", {
  position = popup_position,
  width = popup_width,
  align = "left",
  padding_left = 14,
  padding_right = 14,
  label = { string = "CPU --%   ·   Memory --%", color = colors.subtext },
})

local process_rows = {}
for index = 1, process_rows_count do
  process_rows[index] = sbar.add("item", "monitor.process." .. index, {
    position = popup_position,
    width = popup_width,
    align = "left",
  padding_left = 14,
  padding_right = 14,
    label = { string = "", font = { family = settings.font.numbers } },
    drawing = false,
  })
end

local open_row = sbar.add("item", "monitor.open", {
  position = popup_position,
  width = popup_width,
  align = "left",
  padding_left = 14,
  padding_right = 14,
  label = { string = "Open bottom", color = colors.subtext },
})

local function color_for(percentage)
  if percentage >= 85 then return colors.red end
  if percentage >= 60 then return colors.orange end
  return colors.text
end

local function refresh()
  sbar.exec(QUERY, function(result)
    result = result or ""
    local idle = tonumber(result:match("([%d%.]+)%%%s+idle"))
    local free = tonumber(result:match("free percentage:%s*(%d+)"))

    local cpu_used = idle and math.floor(100 - idle + 0.5)
    local memory_used = free and (100 - free)

    if cpu_used then
      cpu:set({ label = { string = cpu_used .. "%", color = color_for(cpu_used) } })
    end
    if memory_used then
      memory:set({ label = { string = memory_used .. "%", color = color_for(memory_used) } })
    end
    header_row:set({
      label = "CPU " .. (cpu_used or "--") .. "%   ·   Memory " .. (memory_used or "--") .. "%",
    })
  end)
end

local function refresh_processes()
  sbar.exec(PROCESS_QUERY, function(result)
    local index = 0
    for line in (result or ""):gmatch("[^\r\n]+") do
      local usage, command = line:match("^%s*([%d%.]+)%s+(.+)$")
      -- The first line is the `ps` header, which has no numeric usage.
      if usage and command then
        index = index + 1
        if index <= process_rows_count then
          process_rows[index]:set({
            drawing = true,
            label = string.format("%5.1f%%  %s", tonumber(usage), command:match("([^/]+)$") or command),
          })
        end
      end
    end
    for empty = index + 1, process_rows_count do
      process_rows[empty]:set({ drawing = false })
    end
  end)
end

local function hide_popup()
  monitor_bracket:set({ popup = { drawing = false } })
end

cpu:subscribe({ "routine", "forced", "system_woke" }, refresh)

local function toggle_popup()
  local should_draw = monitor_bracket:query().popup.drawing == "off"
  if should_draw then
    refresh()
    refresh_processes()
    monitor_bracket:set({ popup = { drawing = true } })
  else
    hide_popup()
  end
end

cpu:subscribe("mouse.clicked", toggle_popup)
memory:subscribe("mouse.clicked", toggle_popup)
cpu:subscribe("mouse.exited.global", hide_popup)
memory:subscribe("mouse.exited.global", hide_popup)

-- `bottom` is already provisioned by `packages/Brewfile`.
open_row:subscribe("mouse.clicked", function()
  hide_popup()
  sbar.exec("open -a WezTerm --args start -- btm")
end)

refresh()
