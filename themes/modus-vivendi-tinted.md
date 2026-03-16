# Modus Vivendi Tinted

WCAG AAA compliant dark color scheme by Protesilaos Stavrou.
Counterpart to Modus Operandi Tinted (light).

- https://protesilaos.com/emacs/modus-themes

## Core Palette

| Name | Hex | RGB |
|------|-----|-----|
| bg-main | `#0d0e1c` | 13, 14, 28 |
| bg-dim | `#1d1f2f` | 29, 31, 47 |
| fg-main | `#ffffff` | 255, 255, 255 |
| fg-dim | `#989898` | 152, 152, 152 |
| bg-active | `#4a4f69` | 74, 79, 105 |

## Application Configs

### Ghostty

```
theme = Modus Vivendi Tinted
```

### Cursor

```json
{
    "workbench.colorTheme": "Modus Vivendi Tinted"
}
```

### Zed

```json
{
  "theme": {
    "mode": "dark",
    "light": "Modus Operandi Tinted",
    "dark": "Modus Vivendi Tinted"
  }
}
```

### Slack

Follows macOS system appearance automatically.

### Chrome

Switch Dark Reader to **Dark** mode. Suggested settings:

| Slider | Value |
|--------|-------|
| Mode | Dark |
| Brightness | 0 |
| Contrast | 0 |
| Sepia | 0 |
| Grayscale | 0 |

### macOS

Use Dark appearance. Wallpaper is set automatically by `toggle-theme`
using `macos/wallpapers/modus-vivendi-tinted.png` (`#0d0e1c`).
