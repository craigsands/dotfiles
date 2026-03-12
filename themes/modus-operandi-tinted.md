# Modus Operandi Tinted

WCAG AAA compliant color scheme by Protesilaos Stavrou.

- https://protesilaos.com/emacs/modus-themes

## Core Palette

| Name | Hex | RGB |
|------|-----|-----|
| bg-main | `#fbf7f0` | 251, 247, 240 |
| bg-dim | `#efe9dd` | 239, 233, 221 |
| fg-main | `#000000` | 0, 0, 0 |
| fg-dim | `#595959` | 89, 89, 89 |
| bg-active | `#c9b9b0` | 201, 185, 176 |

## Application Configs

### Ghostty

```
theme = Modus Operandi Tinted
```

### Cursor

The `wroyca.modus` extension is not available in Cursor's marketplace and must be
installed from VSIX downloaded from the VS Code marketplace:

```bash
curl -sL "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/wroyca/vsextensions/modus/latest/vspackage" \
  -o /tmp/wroyca.modus.vsix.gz
gunzip /tmp/wroyca.modus.vsix.gz
cursor --install-extension /tmp/wroyca.modus.vsix
```

```json
{
    "workbench.colorTheme": "Modus Operandi Tinted"
}
```

### Zed

Install extension: Search "modus" in `zed: extensions`

```json
{
  "theme": {
    "mode": "light",
    "light": "Modus Operandi Tinted",
    "dark": "Modus Vivendi Tinted"
  }
}
```

### Slack

Sidebar only (Preferences > Themes > Custom):

| Field | Hex |
|-------|-----|
| System navigation | `#fbf7f0` |
| Selected items | `#c9b9b0` |
| Presence indication | `#006300` |
| Notifications | `#a60000` |

### Chrome

See `chrome/README.md` for Dark Reader extension settings.

### macOS

Use Light appearance.

**Wallpaper (manual):**
1. System Settings > Wallpaper > Custom Color
2. RGB Sliders: R: 251, G: 247, B: 240
