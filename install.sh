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

# Symlink a config file
link_config() {
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
    ln -s "$src" "$dest"
    info "Linked: $dest -> $src"
}

# Ghostty configuration
install_ghostty_config() {
    info "Installing Ghostty config..."
    link_config "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
}

# Cursor configuration
install_cursor_config() {
    info "Installing Cursor config..."
    local cursor_dir="$HOME/Library/Application Support/Cursor/User"
    mkdir -p "$cursor_dir"
    link_config "$DOTFILES_DIR/cursor/settings.json" "$cursor_dir/settings.json"
}

# Zed configuration
install_zed_config() {
    info "Installing Zed config..."
    mkdir -p "$HOME/.config/zed"
    link_config "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
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

# macOS preferences
install_macos_config() {
    info "Applying macOS preferences..."
    source "$DOTFILES_DIR/macos/defaults.sh"
}

# Main
main() {
    local component="${1:-all}"
    
    case "$component" in
        all)
            install_homebrew
            install_brew_packages
            install_ghostty_config
            install_cursor_config
            install_git_config
            install_shell_config
            install_macos_config
            ;;
        brew)
            install_homebrew
            install_brew_packages
            ;;
        ghostty)
            install_ghostty_config
            ;;
        cursor)
            install_cursor_config
            ;;
        zed)
            install_zed_config
            ;;
        git)
            install_git_config
            ;;
        shell)
            install_shell_config
            ;;
        macos)
            install_macos_config
            ;;
        *)
            error "Unknown component: $component"
            ;;
    esac
    
    info "Done!"
}

main "$@"
