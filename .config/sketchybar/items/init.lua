-- Sketchybar stacks each side from its screen edge inward: the first item
-- required for a side ends up closest to that side's edge, later ones stack
-- toward the center. The Apple menu sits at the true left edge, matching
-- the default macOS bar, with AeroSpace workspaces right after it. Everything
-- else clusters on the right, in the order originally requested, with the
-- calendar/clock at the true right edge and the menu bar extras innermost
-- (now playing lives inside the sound popup, not its own item).

-- Left side, edge to center: Apple menu, AeroSpace workspaces.
require("items.apple")
require("items.aerospace")

-- Right side, edge to center: calendar, divider, battery, wifi, bluetooth,
-- language, mic, sound (now playing folded into its popup), CPU/memory,
-- microphone and camera indicators, menu bar extras behind a chevron.
require("items.calendar")
require("items.divider")
require("items.battery")
require("items.wifi")
require("items.bluetooth")
require("items.language")
require("items.microphone")
require("items.sound")
require("items.monitor")
require("items.indicators")
require("items.menu_extras")
