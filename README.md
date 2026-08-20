# macsify

Opinionated `macOS` configuration via shell scripts.

<!-- Screenshots coming soon -->

## Features

| Category | Details |
| -------- | ------- |
| Shell | `Fish` + `Starship` + `Atuin` |
| Terminal | `WezTerm` |
| Editors | `Helix`, `VS Code`, `DataGrip` |
| Window Manager | `AeroSpace` + `SwipeAeroSpace` + `DockDoor` |
| Menu Bar | `SketchyBar`, `barik`-styled, black (notch-hiding) or light theme |
| Development Languages | `Node.js`, `Python`, `Go`, `Java`, `Ruby`, `.NET` (via `mise`) |
| Keyboard | Remapping with persistence (`kbcs` for cheat sheet) |
| Shell Abbreviations | Custom aliases (`alcs` for cheat sheet) |
| Clipboard | `Maccy` |
| Screenshots | `Flameshot` |
| Keep Awake | `Amphetamine` |
| Appearance | Dark mode + custom wallpapers |
| Security | `1Password` + Firewall + stealth mode enabled |
| Cleanup | `Mole` + Bloatware removal |
| Automation | Login and `Dock` items auto-configured |
| Authentication | `TouchID` for `sudo` |
| Progressive Web Applications | via `Google Chrome` |
| Packages | See [Brewfile](packages/Brewfile), [Additional Packages](packages/additional_packages.txt), and [Store applications](packages/store_applications_ids.txt) |

## Pre-Installation

1. Install `Xcode Command Line Tools` by typing `xcode-select --install` and follow the on-screen instructions.

2. Grant Terminal permissions (`System Settings → Privacy & Security`):

    - **Files & Folders** → Add Terminal
    - **Full Disk Access** → Add Terminal
    - **Accessibility** → Add Terminal

3. Customize packages and application lists:

    - Edit [packages/Brewfile](packages/Brewfile).
    - Edit [packages/additional_packages.txt](packages/additional_packages.txt).
    - Edit [packages/store_applications_ids.txt](packages/store_applications_ids.txt).

4. Configure `AI` models:

    - Edit [.config/agentic/models.txt](.config/agentic/models.txt) for all `OpenCode` and `Claude Code` model assignments.

## Installation

```bash
./install.sh
```

## Post-Installation

### App Permissions

`System Settings → Privacy & Security`:

| App | Full Disk Access | Accessibility | Screen Recording | Developer Tools |
| --- | ---------------- | ------------- | ---------------- | --------------- |
| `WezTerm` | ✓ | ✓ | | ✓ |
| `VS Code` | | | | ✓ |
| `AeroSpace` | | ✓ | | |
| `DockDoor` | | ✓ | ✓ | |
| `Flameshot` | | | ✓ | |
| `Google Drive` | | ✓ | | |
| `Maccy` | | ✓ | | |
| `SketchyBar` | | ✓ | | |
| `SwipeAeroSpace` | | ✓ | | |

### Keyboard Configuration

**Modifier Keys** (`System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys`):

> Keys (left to right):
>
> - `Key 1` = Globe (`Apple`) / Control (`Windows/PC`)
> - `Key 2` = Control (`Apple`) / Super (`Windows/PC`)
> - `Key 3` = Option (`Apple`) / Alt (`Windows/PC`)

*Apple keyboards (internal/external):*

| Key | Mapping |
| ---- | ------- |
| Globe | Command |
| Control | Option |
| Option | Control |

*Non-Apple keyboards (use `Windows/PC` mode, not `macOS`):*

| Key | Mapping |
| ---- | ------- |
| Control | Command |
| Command | Option |
| Option | Control |

### Display

`System Settings → Displays`:

- Disable **`True Tone`**

### `Finder`

Open `Finder` and configure sidebar:

- Remove: Recents, Shared, `iCloud`, `AirDrop`
- Add to Locations: `Home` folder
- Add to Favorites: `Developer` folder

### `1Password`

- [Enable SSH key management](https://developer.1password.com/docs/ssh/get-started).
- [Enable commit signing](https://1password.com/blog/git-commit-signing).
- Configure keyboard shortcuts (`Settings → General → Keyboard Shortcuts`):
  - Autofill: `Key 2 + Shift + A`
  - Quick Access: `Key 2 + Shift + S`
  - Clear remaining shortcuts to avoid conflicts.

### `SketchyBar` Menu Bar

The native menu bar is hidden and replaced. Click `›` at the inner end of the right cluster to bring the native one back for a few seconds when you need an app's menu extras.

- Theme (black/light) and the language picker's sources follow `System Settings` automatically, nothing to configure. The theme switches live, no reload needed.
- Add your calendar accounts (`iCloud`, `Google`, etc.) under `System Settings → Internet Accounts` so the calendar popup's `Calendar.app` shows everything.
- Grant `SketchyBar` Accessibility access when macOS prompts, it is what opens the real `Apple` menu.
- Grant `SketchyBar` `Bluetooth` access under `System Settings → Privacy & Security → Bluetooth`. Until you do, `blueutil` blocks on its own permission prompt and the `Bluetooth` widget stays empty.
- The Wi-Fi popup shows `Connected` instead of the network name unless `SketchyBar` also has `Location Services`. macOS has withheld the `SSID` from command line tools without it since `Sonoma`.
- Microphone and camera indicators only appear while something is using them. `Bluetooth` microphones do not report their state to macOS, so those never light up.

### `PWA`s

1. Open `Google Chrome` and visit:
   - [`Google Messages`](https://messages.google.com/web)
   - [`Google Photos`](https://photos.google.com/)

2. For each site, go to `Chrome main menu → Cast, Save, and Share → Install Page as App...` and follow the on-screen instructions.

3. Enable `chrome://settings/content → Additional content settings → On-device site data → Allow sites to save data on your device`
