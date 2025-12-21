#!/bin/bash

# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e


# Constant variable of the scripts' working directory to use for relative paths.
APPLICATIONS_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$APPLICATIONS_SCRIPT_DIRECTORY/../helpers/logs.sh"

# Declare application configuration sources, destinations and names.
APPLICATIONS_SOURCES=(
  "$APPLICATIONS_SCRIPT_DIRECTORY/../settings/aerospace.toml"
  "$APPLICATIONS_SCRIPT_DIRECTORY/../settings/org.p0deje.Maccy.plist.xml"
)

APPLICATIONS_DESTINATIONS=(
  "$HOME/.config/aerospace/aerospace.toml"
  "$HOME/Library/Containers/org.p0deje.Maccy/Data/Library/Preferences/org.p0deje.Maccy.plist"
)

APPLICATIONS_NAMES=(
  "Aerospace"
  "Maccy"
)

# Loop over all arrays in parallel.
for i in "${!APPLICATIONS_SOURCES[@]}"; do
  source="${APPLICATIONS_SOURCES[$i]}"
  destination="${APPLICATIONS_DESTINATIONS[$i]}"
  process_name="${APPLICATIONS_NAMES[$i]}"

  # Check if the source configuration file exists.
  if [ -f "$source" ]; then
    log_info "Restoring '$process_name' configuration..."
    killall "$process_name" 2>/dev/null || true
    killall cfprefsd 2>/dev/null || true

    # If the source is a `.plist.xml`, convert to binary `plist`.
    if [[ "$source" == *.plist.xml ]]; then
      plutil -convert binary1 -o "$destination" "$source"
    else
      # For regular files, just copy them to their destination.
      mkdir -p "$(dirname "$destination")"
      cp "$source" "$destination"
    fi
  fi
done

log_success "All applications configurations restored successfully."
