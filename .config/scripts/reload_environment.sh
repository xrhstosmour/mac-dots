#!/bin/bash

# Reload environment.
aerospace reload-config
aerospace flatten-workspace-tree
~/.config/scripts/configure_workspaces.sh
sudo ~/.config/scripts/keyboard.sh apply_keyboard_configuration
