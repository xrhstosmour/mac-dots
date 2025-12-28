# Dotfiles

macOS system configuration via shell scripts.

## Features

- Developer Setup
  - Setup: `Xcode`, `Homebrew`, `Git`, `Fish`, `Starship`, `mise`
  - Languages: `.NET Core`, `Go`, `Java`, `Node.js`, `Python`, `Ruby`
- System configuration (`Finder`, Dock, Menu Bar, Display, Audio, Trackpad, `TouchID`)
- Keyboard remapping with persistence and cheat sheet
- Window/Tiling manager (`AeroSpace`)
- Appearance (themes, wallpapers, dark mode)
- Security (firewall, stealth mode, file-sharing whitelist)
- Cleanup (remove default macOS applications)

## Requirements

- macOS 12+ (Intel or Apple Silicon)

## Installation

Execute with administrative privileges: `./install.sh`

The installer will prompt for approvals before making changes.

## Packages

**CLI Tools**

- `1password-cli`
- `aria2`
- `atuin`
- `bat`
- `bottom`
- `displayplacer`
- `eva`
- `eza`
- `fastfetch`
- `fd`
- `fdupes`
- `ffmpeg`
- `fish`
- `fisher`
- `fzf`
- `gh`
- `goto-ssh`
- `helix`
- `jless`
- `kdiff3`
- `mas`
- `mise`
- `mole`
- `scrcpy`
- `sd`
- `starship`
- `superfile`
- `telnet`
- `tig`
- `witr`
- `xh`
- `zoxide`

**GUI Apps**

- `1password`
- `android-platform-tools`
- `aerospace`
- `brave-browser`
- `docker`
- `filen`
- `flameshot`
- `font-fira-code`
- `google-chrome`
- `google-drive`
- `localsend`
- `maccy`
- `macfuse`
- `nordvpn`
- `obsidian`
- `postman`
- `signal`
- `spotify`
- `sublime-text`
- `syncthing`
- `utm`
- `veracrypt`
- `viber`
- `visual-studio-code`
- `vlc`
- `wailbrew`
- `wezterm`
- `whatsapp`

**App Store**: `Perplexity AI`, `Amphetamine`

## Permissions/Requirements

- **Full Disk Access**: `System Settings` → `Privacy & Security` → `Full Disk Access`
  - Terminal used for running the installation script.
  - `WezTerm`
- **Developer Tools**: `System Settings` → `Privacy & Security` → `Developer Tools`
  - `WezTerm`
  - `Visual Studio Code`
- **Input Monitoring**: `System Settings` → `Privacy & Security` → `Input Monitoring`
  - `/usr/bin/hidutil`, for keyboard remapping scripts.
  - `/usr/bin/sudo`, for keyboard remapping scripts.
- **Accessibility**: `System Settings` → `Privacy & Security` → `Accessibility`
  - Terminal used for running the installation script.
  - `AeroSpace`
  - `Maccy`
  - `SwipeAeroSpace`
  - `WezTerm`
- **GitHub CLI**: Run `gh auth login` to authenticate with `GitHub CLI` before using corresponding abbreviations/functions.
