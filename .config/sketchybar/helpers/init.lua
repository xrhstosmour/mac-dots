-- Add the sketchybar-lua module to the package cpath (installed by
-- `setup/sketchybar.sh` via the `SbarLua` makefile).
package.cpath = package.cpath .. ";" .. os.getenv("HOME") .. "/.local/share/sketchybar_lua/?.so"

os.execute("(cd helpers && make)")
