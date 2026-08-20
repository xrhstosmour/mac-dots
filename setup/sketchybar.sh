#!/bin/bash

# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
SKETCHYBAR_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$SKETCHYBAR_SCRIPT_DIRECTORY/../helpers/logs.sh"

SKETCHYBAR_CONFIG_DIRECTORY="$HOME/.config/sketchybar"
SBARLUA_INSTALL_DIRECTORY="$HOME/.local/share/sketchybar_lua"

log_info "Configuring 'SketchyBar'..."

# Install the `SbarLua` lua module, if not already installed.
if [ ! -d "$SBARLUA_INSTALL_DIRECTORY" ]; then
  log_info "Installing 'SbarLua'..."
  git clone --quiet https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua
  (cd /tmp/SbarLua && make install)
  rm -rf /tmp/SbarLua
else
  log_warning "'SbarLua' is already installed."
fi

# Make the entrypoint and helper build scripts executable.
chmod +x "$SKETCHYBAR_CONFIG_DIRECTORY/sketchybarrc"

# Build the compiled helper binaries (the Accessibility-based menu helper).
log_info "Building 'SketchyBar' helper binaries..."
make -C "$SKETCHYBAR_CONFIG_DIRECTORY/helpers"

# Start (or restart) the `SketchyBar` background service.
log_info "Starting 'SketchyBar'..."
brew services restart sketchybar

log_success "'SketchyBar' configuration applied successfully."
log_divider
