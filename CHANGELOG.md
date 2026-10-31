# Changelog

All notable changes to ArcWicky are documented here.

## 2.0.0 — 2026-10-31

Complete reimagining of the launcher under the **Tactile Vinyl & Spatial Cartoon** design system with Apple Silicon M-series tuning.

### Added

- **Screen 1 — Living Typographic Sculpture Intro:** Kinetic typographic sculpture of "ARCWICKY" with staggered drop-in boing entrance, 3D rubber physics, rim lighting, and specular highlights without progress bars or spinners.
- **Screen 2 — Stage Spotlight & Orbital Carousel:** 3:4 proportional 3D squircle toy cards, animated inflatable vinyl title deck, specification capsules, and monumental Glacial Mint (`#DDF8FA`) `PLAY!` trigger button.
- **Screen 3 — The Wine Toy-Lab:** Interactive graphics translation laboratory featuring an Apple Silicon M2 Pro load dial, a 4-Way Mechanical Rotary Engine Selector (DXMT, D3DMetal GPTK 2.0, DXVK, WineD3D), and three animated bulbous cartoon chemistry flasks with bubbling liquids.
- **Floating Bottom Console Dock:** Centered dock navigation bar with quick switching between Playground, Stores & Loot, Wine Toy-Lab, and Activity Logs.
- **Top Command Deck:** Clean header with centered search capsule, active controller telemetry (`DualSense Connected • 94%`), and 3D extruded `+ Add .EXE` pill button (logo removed from top-left for clean layout).
- **Expanded Store Support:** Integrated Amazon Prime Games and itch.io browser runners alongside Steam, Epic Games, and GOG.
- **Free Weekly Loot Showcase:** Curated promotional section highlighting active free game drops from Epic Games.
- **Polar Fusion Palette:** Velvet night canvases (`#090B11`, `#111725`, `#181F31`), deep slate structural boundaries (`#303B59`), and crisp specular mint accents (`#CDE8EA`, `#DDF8FA`, `#DCE8FF`).

### Removed

- Removed legacy rigid sidebar and obsolete header banners.
- Deprecated and removed legacy Vermut branding assets, wordmark generators, and unused emoji components.

---

## 1.2.0 — 2026-10-23

Promotes the QA’d `1.2.0-beta.4` line to stable.

### Added

- In-app update checker with **Stable** / **Beta** channels (Settings › General)
- DXMT multi-version manager (default v0.80) in Settings › Components
- Gcenx Wine Staging / Devel 11.18 engines, downloadable on demand, with GStreamer handling
- D3DMetal manual detection, validation, and install guide
- Per-game settings (Library inspector, ⌥⌘I): Wine engine, graphics backend, DXMT version, and log level, with Automatic inheriting from the store
- Custom Wine bottles: create and manage extra bottles with engine and graphics backend
- Steam library covers for newer apps
- **Remove ArcWicky Data…**: selective uninstall of bottles, engines, cache, and preferences

### Fixed

- Steam launch reliability: first-run restart, window activation, `-applaunch`, Installed gated on the real client
- Quit / cleanup: stop Wine and bottle Steam processes without SIGKILL of native macOS Steam `ipcserver`
- Onboarding step counter matches the real step count
- Custom bottle Running state stays reactive
- D3DMetal / DXVK unavailable options are rejected; bottle create is gated on name length

---

## 1.1.2 — 2026-10-20

### Fixed

- SwiftPM resource bundles (colour tokens, brand assets) bundled in `Contents/Resources` and located cleanly without build machine fallback paths.
- The startup colour-token check is now debug-only and never fatal.
- Store status refresh reliability during installation.
- Steam launch synchronization tweaks using msync mode.
- `build.sh` smoke test verification.

---

## 1.1.0 — 2026-10-20

### Added

- Community compatibility reports system.
- Terminal installer (`curl -fsSL ... | bash`).

---

## 1.0.0 — 2026-10-19

First public release of the Apple Silicon Wine game launcher.
