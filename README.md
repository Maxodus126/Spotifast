<h3 align="center"><img src=".github/assets/logo.svg" width="300px"></h3>
<p align="center">
  <a href="https://github.com/Maxodus126/Spotifast/releases/latest"><img src="https://img.shields.io/github/release/Maxodus126/Spotifast/all.svg?colorB=97CA00&label=latest%20version"></a>
  <a href="https://github.com/Maxodus126/Spotifast/releases"><img src="https://img.shields.io/github/downloads/Maxodus126/Spotifast/total.svg?colorB=97CA00&label=total%20downloads"></a>
</p>

---

Command-line tool to customize the official Spotify client.
Supports Windows, macOS and Linux.

### Features

- Change colors across the User Interface
- Inject CSS for advanced customization
- Inject Extensions to extend functionalities, manipulate UI and control player
- Inject Custom Apps
- Make yourself in control of the Spotify client

### Installation

Spotify (desktop version from [spotify.com](https://www.spotify.com/download/) — not the Microsoft Store version) must already be installed.

**Windows (PowerShell):**

```powershell
iwr -useb https://raw.githubusercontent.com/Maxodus126/Spotifast/main/install.ps1 | iex
```

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/Maxodus126/Spotifast/main/install.sh | sh
```

Then customize:

```powershell
spotifast backup
spotifast apply
```

To remove spotifast, use `uninstall.ps1` (Windows) / `uninstall.sh` (macOS/Linux).

### Links

- [Releases](https://github.com/Maxodus126/Spotifast/releases)
- [Issues](https://github.com/Maxodus126/Spotifast/issues)
- [Spotifast Marketplace](https://github.com/Maxodus126/spotifast-marketplace)

### Notes

- Does NOT remove ads. Ad-free listening requires Spotify Premium.
- Modifying the Spotify client violates its Terms of Service; use at your own risk.

### Credits

Spotifast is a rebranded fork of [Spicetify CLI](https://github.com/spicetify/cli),
licensed under LGPL-2.1. Copyright belongs to the original Spicetify contributors.
