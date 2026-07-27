# zxhud — FiveM HUD Resource

A dark, cyberpunk-styled FiveM HUD with a warm gold accent, a smart camera/surveillance zone system, and an in-game settings menu for live color customization, cinematic mode, and configurable minimap behavior.

<img width="661" height="370" alt="zxhud preview" src="https://github.com/user-attachments/assets/7c3b0f7f-44dc-4b87-bcea-10118dc1cf2b" />

---

## Table of Contents
- [Features](#features)
- [Settings Menu](#settings-menu)
- [Camera Zone Ability](#camera-zone-ability)
- [Installation](#installation)
- [Configuration](#configuration)
  - [Camera Zones](#camera-zones)
  - [Extras (Menu / Cinematic / Minimap)](#extras-menu--cinematic--minimap)
- [Keybinds](#keybinds)
- [File Structure](#file-structure)
- [Dependencies](#dependencies)
- [Troubleshooting / FAQ](#troubleshooting--faq)
- [Credits](#credits)

---

## Features
- Dark cyberpunk theme with a customizable gold accent (`#967969` by default)
- Custom minimap overlay with circle / square skins
- Camera status indicator — the on-screen icon turns **green** when the player enters a monitored surveillance zone
- Gear, speed, fuel, and engine temperature readouts for vehicles
- Smooth CSS animations and glassmorphism panels
- In-game settings menu: live accent color picker, cinematic mode, and configurable minimap visibility
- All player preferences persist across sessions (server-side KVP storage)

## Settings Menu
Press the configured menu key (default: **I**) to open the ZXHUD settings menu in-game.

| Option | What it does |
|---|---|
| **Accent Color** | 8 built-in presets plus a custom color picker / hex input. Updates the HUD's gold accent instantly and live. |
| **Cinematic Mode** | Hides the HUD and fades in black letterbox bars top and bottom. Also hides GTA's native HUD (wanted stars, cash, ammo, etc). Quick toggle key: **F7**. |
| **Minimap Display** | Choose **Always**, **In Vehicle Only** (classic behavior — map only shows while driving), or **Off**. |

All choices are saved automatically via `SetResourceKvp` and restored on the player's next session. Defaults, presets, and keybinds are all configurable — see [Configuration](#configuration) below.

> **Note:** the accent color picker changes the HUD's gold-themed elements (icons, gear/RPM text, fuel & engine rings, filled segments). Health/armor/hunger/thirst indicators keep their own fixed colors by design.

## Camera Zone Ability
When a player enters a configured camera/surveillance zone, the HUD icon lights up green and the resource can be extended to trigger:
- Notifying nearby police / authorities
- Logging the player's presence in the zone
- Triggering a wanted level or alert system
- Blocking or allowing certain actions inside the zone

Zones are checked on an interval (see `Config.ZoneCheckInterval`) so this stays lightweight even with many zones defined.

## Installation
1. Download or clone this repository into your server's `resources` directory.
2. Rename the folder to `zxhud` if it isn't already.
3. Add the following to your `server.cfg`:
   ```cfg
   ensure zxhud
   ```
4. Restart your server (or `refresh` + `ensure zxhud` from the console).

## Configuration

### Camera Zones
Add, remove, or edit surveillance zones in `config.lua`:
```lua
Config.CameraZones = {
    {
        label  = "Police Station – Mission Row",
        coords = vector3(399.09, -1007.39, 56.67),
        radius = 120.0,
    },
    -- Add more zones here
}

-- How often (ms) the zone check runs when the player is on foot.
-- Lower = more responsive, higher = slightly better performance.
-- Recommended: 500 – 1000
Config.ZoneCheckInterval = 600
```

### Extras (Menu / Cinematic / Minimap)
Also in `config.lua`, under `Config.Extras`:
```lua
Config.Extras = {
    MenuKey      = "I",   -- key to open the settings menu (rebindable per-player too)
    CinematicKey = "F7",  -- quick toggle for cinematic mode

    DefaultAccentColor = "#967969",

    ColorPresets = {
        { name = "Gold (default)", hex = "#967969" },
        { name = "Crimson",        hex = "#c8433a" },
        { name = "Cyan",           hex = "#3ac8c0" },
        { name = "Violet",         hex = "#8a5fd6" },
        { name = "Emerald",        hex = "#3ac87a" },
        { name = "Ice Blue",       hex = "#6fa9d8" },
        { name = "Amber",          hex = "#d69a3a" },
        { name = "Rose",           hex = "#d65f96" },
    },

    -- "always" | "vehicle" | "never"
    DefaultMapMode = "vehicle",

    Cinematic = {
        BarHeightVh   = 12,   -- height (vh) of the top/bottom letterbox bars
        FadeMs        = 500,  -- fade speed in/out of cinematic mode
        HideNativeHud = true, -- also hides GTA's native HUD elements
    },
}
```

`MenuKey` / `CinematicKey` accept any valid [FiveM key mapping name](https://docs.fivem.net/docs/game-references/controls/) (e.g. `F1`–`F12`, `U`, `K`, `HOME`, `INSERT`, `PAGEUP`, `LMENU`). These are just the **defaults** — each player can still rebind their own copy under *Settings → Key Bindings → FiveM → "zxhud"*.

## Keybinds
| Key (default) | Action |
|---|---|
| `I` | Open / close the settings menu |
| `F7` | Toggle cinematic mode |

Chat command alternatives are also available: `/hudmenu` and `/hudcinematic`.

## File Structure
```
zxhud/
├── client/
│   ├── Main.lua       -- core HUD loop, vehicle stats, minimap trigger
│   ├── camera.lua      -- camera zone detection
│   └── extras.lua      -- settings menu, cinematic mode, minimap mode, KVP persistence
├── html/
│   ├── index.html       -- HUD renderer (do not edit — see note below)
│   ├── app.js            -- HUD renderer logic (do not edit — see note below)
│   ├── camera.js          -- camera status UI logic
│   ├── extras.js          -- settings menu UI + live theming (safe to edit/extend)
│   └── style.css           -- HUD styling & CSS variables (safe to edit)
├── stream/                  -- minimap texture assets
├── config.lua                -- all configuration
└── fxmanifest.lua
```

> `index.html` and `app.js` ship minified/obfuscated to protect the original HUD renderer. All new functionality (menu, cinematic mode, minimap mode) was built as separate, additive files (`extras.lua` / `extras.js`) that hook into the CSS variables and Lua functions the HUD already exposes, rather than modifying that protected code.

## Dependencies
- `/assetpacks`

## Troubleshooting / FAQ

**The menu key doesn't open anything.**
Make sure the resource restarted after any config change (`restart zxhud` or `refresh` + `ensure zxhud`). Also check the F8 client console for Lua errors on resource start.

**My menu key conflicts with another resource (e.g. inventory).**
Pick a different `MenuKey` in `config.lua`, or have players rebind it individually under *Settings → Key Bindings → FiveM → "zxhud"*.

**The color picker doesn't change health/armor colors.**
That's expected — those bars use fixed colors in `style.css` by design. Only the gold-accented elements follow the picker.

**Minimap won't hide in "Off" mode.**
Cinematic mode always forces the minimap off regardless of the minimap setting; outside of cinematic mode, confirm `Config.Extras.DefaultMapMode` or your saved menu choice is actually `"never"`.

## Credits
Made by zizooux
