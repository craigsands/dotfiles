# dotfiles

Personal machine configuration for macOS. Optimized for eye health using the Modus Operandi Tinted color scheme.

## Quick Start

```bash
git clone https://github.com/craigsands/dotfiles.git ~/code/craigsands/dotfiles
cd ~/code/craigsands/dotfiles
./install.sh
```

## What's Included

| Path | Purpose |
|------|---------|
| `bin/` | Scripts (`toggle-theme`, `claude-statusline`) |
| `chrome/` | Chrome browser settings (Dark Reader) |
| `cursor/` | Cursor editor settings |
| `ghostty/` | Ghostty terminal configuration |
| `git/` | Global gitignore |
| `macos/` | macOS system preferences |
| `shell/` | Zsh configuration (zoxide, yazi `y` wrapper) |
| `themes/` | Color scheme documentation |
| `zed/` | Zed editor settings (AI disabled, for Windows) |
| `Brewfile` | Homebrew packages |

## Color Scheme

Uses [Modus themes](https://protesilaos.com/emacs/modus-themes) (WCAG AAA compliant, designed to reduce eye strain):

- **Light**: Modus Operandi Tinted (`themes/modus-operandi-tinted.md`)
- **Dark**: Modus Vivendi Tinted (`themes/modus-vivendi-tinted.md`)

## Toggle Light/Dark

```bash
toggle-theme          # toggle from current mode
toggle-theme dark     # switch to dark
toggle-theme light    # switch to light
```

Toggles macOS system appearance + wallpaper, Ghostty, Cursor, and Zed in one command.

**Note**: Run from macOS Terminal.app or Cursor's terminal, not from within Ghostty.

## Claude CLI Status Line

```bash
claude-statusline
```

Self-documenting status line for Claude CLI that displays:
- Color-coded model names (Opus=orange, Sonnet=green, Haiku=yellow)
- Mode badges ([MAX], [THINK])
- Context window progress bar with percentage
- Current directory and git branch
- Agent name, worktree name (if applicable)
- Cost, token count, duration

All configuration, testing instructions, and customization options are documented in the script's header comments. Run `head -n 80 ~/code/craigsands/dotfiles/bin/claude-statusline` to view.

### Install Status Line

```bash
./install.sh statusline
```

This will:
1. Copy the script to `~/.local/bin/claude-statusline`
2. Configure Claude CLI to use it automatically

## Install Specific Components

```bash
./install.sh brew
./install.sh cursor
./install.sh ghostty
./install.sh git
./install.sh macos
./install.sh shell
./install.sh statusline
./install.sh zed
```
