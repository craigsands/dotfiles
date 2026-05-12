#!/usr/bin/env bash
# macOS system preferences
# Run with: source macos/defaults.sh

# Close System Preferences to prevent overriding
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# Appearance: Light mode (for Modus Operandi Tinted)
defaults delete NSGlobalDomain AppleInterfaceStyle 2>/dev/null || true

# Finder: Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Wallpaper: Set via toggle-theme or directly
WALLPAPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/wallpapers"
if [[ -f "$WALLPAPER_DIR/modus-operandi-tinted.png" ]]; then
    osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALLPAPER_DIR/modus-operandi-tinted.png\""
fi
