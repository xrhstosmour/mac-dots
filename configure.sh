#!/bin/bash

# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
CONFIGURE_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$CONFIGURE_SCRIPT_DIRECTORY/helpers/logs.sh"

# Install and configure `Homebrew`.
source setup/homebrew.sh

# Install developer tools & programming languages.
source setup/developer.sh
source utilities/development.sh

# Install dependencies and applications.
log_info "Installing needed dependencies and applications..."
brew bundle install --file=packages/Brewfile

# Install `Mac App Store` applications.
# Loop through the list of app IDs in `packages/store_applications_ids.txt`.
if command -v mas &>/dev/null; then
    installed_application_ids=$(mas list | awk '{print $1}')

    while IFS= read -r application_id || [[ -n "$application_id" ]]; do
        [[ -z "$application_id" || "$application_id" =~ ^# ]] && continue

        if grep -qx "$application_id" <<<"$installed_application_ids"; then
            continue
        fi

        mas purchase "$application_id"
    done <packages/store_applications_ids.txt
fi

# Install additional packages from various sources by executing custom installation commands.
if [[ -f packages/additional_packages.txt ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        bash -c "$line" || log_warning "Failed to run additional package command: $line"
    done <packages/additional_packages.txt
fi
log_divider

# Restore installed applications' configurations.
sh setup/applications.sh
log_divider

# Configure shell.
sh setup/shell.sh

# Configure `macOS` Preferences.
sh setup/preferences.sh
