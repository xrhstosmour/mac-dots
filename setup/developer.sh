#!/bin/bash

# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
DEVELOPER_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$DEVELOPER_SCRIPT_DIRECTORY/../helpers/logs.sh"

# Copy `Git` configuration file and configure credentials.
if [ ! -f ~/.gitconfig ]; then
  log_info "Copying 'Git' configuration..."
  cp "$DEVELOPER_SCRIPT_DIRECTORY/../.gitconfig" ~

  log_info "Configuring 'Git'..."
  read -p "Enter your 'Git' name: " git_name
  read -p "Enter your 'Git' email: " git_email

  {
    echo "[user]"
    echo "	name = $git_name"
    echo "	email = $git_email"
  } | cat - ~/.gitconfig > ~/.gitconfig.tmp && mv ~/.gitconfig.tmp ~/.gitconfig
else
  log_info "'Git' is already configured."
fi
log_divider

# Install developer tools.
if ! xcode-select -p &>/dev/null; then
  log_info "Installing 'Xcode' command line tools..."
  xcode-select --install
  log_info "Please follow on-screen instructions for 'Xcode' tools."
else
  log_warning "'Xcode' command line tools are already installed."
fi
