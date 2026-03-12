# dotfiles

Personal machine configuration for macOS. Optimized for eye health using the Modus Operandi Tinted color scheme.

## Quick Start

```bash
git clone https://github.com/craigsands/dotfiles.git ~/code/craigsands/dotfiles
cd ~/code/craigsands/dotfiles
./install.sh
```

## What's Included

| Directory | Purpose |
|-----------|---------|
| `ghostty/` | Ghostty terminal configuration |
| `cursor/` | Cursor editor settings |
| `chrome/` | Chrome browser settings (Dark Reader) |
| `zed/` | Zed editor settings (AI disabled, for Windows) |
| `shell/` | Zsh configuration (zoxide, yazi `y` wrapper) |
| `git/` | Global gitignore |
| `themes/` | Color scheme documentation |
| `macos/` | macOS system preferences |
| `Brewfile` | Homebrew packages |

## Color Scheme

Uses [Modus Operandi Tinted](https://protesilaos.com/emacs/modus-themes) - WCAG AAA compliant, designed to reduce eye strain.

See `themes/modus-operandi-tinted.md` for palette and app-specific configs.

## Install Specific Components

```bash
./install.sh ghostty
./install.sh cursor
./install.sh brew
./install.sh git
./install.sh shell
./install.sh macos
```
