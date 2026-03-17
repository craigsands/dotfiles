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
    local source_line='[[ -f ~/code/craigsands/dotfiles/shell/zshrc ]] && source ~/code/craigsands/dotfiles/shell/zshrc'
    if ! grep -q "dotfiles/shell/zshrc" "$HOME/.zshrc" 2>/dev/null; then
        echo "" >> "$HOME/.zshrc"
        echo "# Dotfiles extras" >> "$HOME/.zshrc"
        echo "$source_line" >> "$HOME/.zshrc"
        info "Added source line to ~/.zshrc"
    else
        info "Source line already in ~/.zshrc"
    fi
}

# Zed configuration
install_zed_config() {
    info "Installing Zed config..."
    mkdir -p "$HOME/.config/zed"
    copy_config "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
}

# Claude CLI status line
install_statusline() {
    info "Installing Claude CLI status line..."
    
    # Create ~/.local/bin if it doesn't exist
    mkdir -p "$HOME/.local/bin"
    
    # Copy the script
    local target="$HOME/.local/bin/claude-statusline"
    if [[ -e "$target" ]]; then
        info "Backing up existing file: $target -> $target.backup"
        mv "$target" "$target.backup"
    fi
    
    cp "$DOTFILES_DIR/bin/claude-statusline" "$target"
    chmod +x "$target"
    info "Copied: claude-statusline -> $target"
    
    # Configure Claude CLI to use it
    if command -v claude &>/dev/null; then
        claude config set statusline.command "$target"
        info "Configured Claude CLI to use statusline"
    else
        info "Claude CLI not found, skipping configuration"
        info "Run 'claude config set statusline.command $target' after installing Claude CLI"
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
            install_statusline
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
        statusline)
            install_statusline
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
