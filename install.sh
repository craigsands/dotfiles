#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { echo "==> $*"; }
error() { echo "ERROR: $*" >&2; exit 1; }

# Install Homebrew if missing
install_homebrew() {
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        info "Homebrew already installed"
    fi
}

# Install packages from Brewfile
install_brew_packages() {
    info "Installing Homebrew packages..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
}

# Copy a config file from the dotfiles repo to its target location
copy_config() {
    local src="$1"
    local dest="$2"

    if [[ -L "$dest" ]]; then
        info "Removing existing symlink: $dest"
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        info "Backing up existing file: $dest -> $dest.backup"
        mv "$dest" "$dest.backup"
    fi

    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    info "Copied: $src -> $dest"
}

# Cursor configuration
install_cursor_config() {
    info "Installing Cursor config..."
    local cursor_dir="$HOME/Library/Application Support/Cursor/User"
    mkdir -p "$cursor_dir"
    copy_config "$DOTFILES_DIR/cursor/settings.json" "$cursor_dir/settings.json"

    if command -v cursor &>/dev/null; then
        if ! cursor --list-extensions 2>/dev/null | grep -q "wroyca.modus"; then
            info "Installing Modus theme extension from VSIX..."
            local vsix="/tmp/wroyca.modus.vsix"
            curl -sL "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/wroyca/vsextensions/modus/latest/vspackage" \
                -o "${vsix}.gz"
            gunzip -f "${vsix}.gz"
            cursor --install-extension "$vsix"
            rm -f "$vsix"
        else
            info "Modus theme extension already installed"
        fi
    else
        info "Cursor CLI not found, skipping extension install"
    fi
}

# Ghostty configuration
install_ghostty_config() {
    info "Installing Ghostty config..."
    copy_config "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
}

# Git global ignore
install_git_config() {
    info "Installing global gitignore..."

    if ! grep -q "dotfiles/git/gitignore_global" "$HOME/.gitconfig" 2>/dev/null; then
        echo "" >> "$HOME/.gitconfig"
        echo "[core]" >> "$HOME/.gitconfig"
        echo "    excludesfile = ~/code/craigsands/dotfiles/git/gitignore_global" >> "$HOME/.gitconfig"
        info "Added excludesfile to ~/.gitconfig"
    else
        info "Excludesfile already in ~/.gitconfig"
    fi
}

# macOS preferences
install_macos_config() {
    info "Applying macOS preferences..."
    source "$DOTFILES_DIR/macos/defaults.sh"
}

# Shell configuration
install_shell_config() {
    info "Installing shell config..."
    stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "shell"
}

# RTK (Rust Token Killer) - LLM token optimization
install_rtk_config() {
    info "Installing RTK hook..."
    if command -v rtk &>/dev/null; then
        rtk init --global
        info "RTK hook installed. Restart Claude Code for it to take effect."
    else
        info "rtk not found, skipping hook install (run ./install.sh brew first)"
    fi
}

# Claude hooks
install_claude_hooks() {
    info "Installing Claude hooks..."

    # Install mdformat via uv
    if ! command -v mdformat &>/dev/null; then
        info "Installing mdformat..."
        uv tool install mdformat
    else
        info "mdformat already installed"
    fi

    local target="$HOME/.local/bin/md-format"
    mkdir -p "$HOME/.local/bin"

    if [[ -e "$target" ]]; then
        info "Backing up existing file: $target -> $target.backup"
        mv "$target" "$target.backup"
    fi

    cp "$DOTFILES_DIR/bin/md-format" "$target"
    chmod +x "$target"
    info "Copied: md-format -> $target"

    local settings="$HOME/.claude/settings.json"
    mkdir -p "$(dirname "$settings")"
    [[ ! -f "$settings" ]] && echo '{}' > "$settings"

    local tmp
    tmp=$(mktemp)
    jq --arg cmd "$target" '
      .hooks.PostToolUse = [
        {"matcher": "Edit|Write", "hooks": [{"type": "command", "command": $cmd}]}
      ]
    ' "$settings" > "$tmp" && mv "$tmp" "$settings"
    info "Registered md-format hook in $settings"
}

# Zed configuration
install_zed_config() {
    info "Installing Zed config..."
    mkdir -p "$HOME/.config/zed"
    copy_config "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
}

# Claude CLI status line
install_statusline_config() {
    info "Installing Claude CLI status line..."

    # Create ~/.claude if it doesn't exist
    mkdir -p "$HOME/.claude"

    # Copy the script
    local target="$HOME/.claude/statusline-command.sh"
    if [[ -e "$target" ]]; then
        info "Backing up existing file: $target -> $target.backup"
        mv "$target" "$target.backup"
    fi

    cp "$DOTFILES_DIR/bin/statusline-command.sh" "$target"
    chmod +x "$target"
    info "Copied: statusline-command.sh-> $target"

    # Configure Claude CLI to use it
    local settings="$HOME/.claude/settings.json"
    if [[ -f "$settings" ]]; then
        # Check if statusLine already exists
        if jq -e '.statusLine' "$settings" >/dev/null 2>&1; then
            info "statusLine already configured in $settings"
        else
            # Add statusLine configuration
            local tmp=$(mktemp)
            jq ". + {\"statusLine\": {\"type\": \"command\", \"command\": \"$target\"}}" "$settings" > "$tmp" && mv "$tmp" "$settings"
            info "Added statusLine configuration to $settings"
        fi
    else
        # Create settings.json with statusLine
        mkdir -p "$(dirname "$settings")"
        cat > "$settings" <<EOF
{
  "statusLine": {
    "type": "command",
    "command": "$target"
  }
}
EOF
        info "Created $settings with statusLine configuration"
    fi

    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        info "Note: Add ~/.local/bin to your PATH by adding this to ~/.zshrc:"
        info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# Main
main() {
    local component="${1:-all}"

    case "$component" in
        all)
            install_homebrew
            install_brew_packages
            install_cursor_config
            install_ghostty_config
            install_git_config
            install_macos_config
            install_shell_config
            install_rtk_config
            install_statusline_config
            install_claude_hooks
            install_zed_config
            ;;
        brew)
            install_homebrew
            install_brew_packages
            ;;
        cursor)
            install_cursor_config
            ;;
        ghostty)
            install_ghostty_config
            ;;
        git)
            install_git_config
            ;;
        macos)
            install_macos_config
            ;;
        shell)
            install_shell_config
            ;;
        rtk)
            install_rtk_config
            ;;
        statusline)
            install_statusline_config
            ;;
        hooks)
            install_claude_hooks
            ;;
        zed)
            install_zed_config
            ;;
        *)
            error "Unknown component: $component"
            ;;
    esac

    info "Done!"
}

main "$@"
