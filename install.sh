#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# PATH
export PATH="$HOME/.local/bin:$PATH"

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

# CLaude configuration
config_claude() {
    info "Installing Claude Code support scripts..."
    stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "claude"
    chmod +x ~/.local/bin/cconf.py

    info "Configuring Claude Code..."
    cconf.py env.DISABLE_TELEMETRY 1
    cconf.py env.ENABLE_TOOL_SEARCH true
    cconf.py attribution.commit ""
    cconf.py attribution.pr ""
    cconf.py model haiku
    cconf.py statusLine.type command
    cconf.py statusLine.command "bash ~/.claude/statusline-command.sh"
    cconf.py effortLevel medium
    cconf.py showClearContextOnPlanAccept true
    cconf.py permissions.defaultMode auto
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

# mdformat (Markdown formatter used by the md-format Claude hook)
install_mdformat() {
    info "Installing mdformat..."
    uv tool install mdformat --with mdformat-frontmatter
}

# Claude hooks
install_claude_hooks() {
    info "Installing Claude hooks..."

    # Install mdformat via uv
    if ! command -v mdformat &>/dev/null; then
        install_mdformat

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

# Main
main() {
    local component="${1:-all}"

    case "$component" in
        all)
            install_homebrew
            install_brew_packages
            install_mdformat
            install_shell_config
            config_claude
            install_cursor_config
            install_ghostty_config
            install_git_config
            install_macos_config
            install_rtk_config
            install_claude_hooks
            install_zed_config
            ;;
        brew)
            install_homebrew
            install_brew_packages
            ;;
        claude)
            config_claude
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
        hooks)
            install_claude_hooks
            ;;
        mdformat)
            install_mdformat
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
