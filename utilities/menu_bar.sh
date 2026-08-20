#!/bin/bash
# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
MENU_BAR_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$MENU_BAR_SCRIPT_DIRECTORY/../helpers/logs.sh"

# Function to apply `Menu Bar` configuration.
# Usage:
#   apply_menu_bar_configuration
apply_menu_bar_configuration() {
    log_info "Applying 'Menu Bar' configuration..."

    # Hide the native `macOS` menu bar entirely. These are the same two keys
    # System Settings' own "Automatically hide and show the menu bar: Always"
    # writes, and the same ones `SketchyBar`'s own author uses for this exact
    # purpose (see FelixKratz/dotfiles `.install.sh`).
    log_info "Hiding the native 'Menu Bar'..."
    defaults write NSGlobalDomain _HIHideMenuBar -bool true
    defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -bool false

    # The keys above only take effect at the next login, verified on a live
    # session, so apply the same change to the running one the way
    # `System Settings` itself does.
    osascript -e 'tell application "System Events" to tell dock preferences to set autohide menu bar to true' >/dev/null

    log_success "'Menu Bar' configuration applied successfully."
    log_divider
}
