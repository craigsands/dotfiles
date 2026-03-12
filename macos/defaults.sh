#!/usr/bin/env bash
# macOS system preferences
# Run with: source macos/defaults.sh

# Close System Preferences to prevent overriding
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# Appearance: Light mode (for Modus Operandi Tinted)
defaults delete NSGlobalDomain AppleInterfaceStyle 2>/dev/null || true

# Finder: Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Wallpaper: Must be set manually (no supported programmatic API for custom colors)
# System Settings > Wallpaper > Custom Color > #fbf7f0 (R:251 G:247 B:240)
echo "Note: Set wallpaper manually to #fbf7f0 - see themes/modus-operandi-tinted.md"
