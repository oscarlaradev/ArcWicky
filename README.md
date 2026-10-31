<p align="center">
  <img src="Resources/AppIcon.iconset/icon_256x256.png" width="128" height="128" alt="ArcWicky">
</p>

<h1 align="center">ArcWicky</h1>

<p align="center"><strong>Tactile Vinyl Gaming Hub for Apple Silicon Macs</strong></p>

<p align="center">
  A native macOS application designed to organize, configure, and launch Windows games seamlessly on Apple Silicon Macs.<br>
  Powered by Wine 11, Metal translation layers, and an exuberant <em>Tactile Vinyl & Spatial Cartoon</em> design system.
</p>

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square"></a>
  <img alt="macOS 14+" src="https://img.shields.io/badge/macOS-14%2B-black?style=flat-square">
  <img alt="Apple Silicon" src="https://img.shields.io/badge/Apple%20Silicon-M--Series-007AFF?style=flat-square">
  <img alt="Tests: 297 passing" src="https://img.shields.io/badge/Tests-297%20passing-27C93F?style=flat-square">
</p>

---

## 🎨 Tactile Vinyl & Spatial Cartoon Design System

ArcWicky breaks away from generic flat dashboards and rigid enterprise toolbars. Built with the **Polar Fusion** color system and kinetic toy minimalism:

* **Screen 1 — Living Typographic Sculpture Intro:** A kinetic vinyl typographic sculpture of **ARCWICKY** greets you upon launch with a staggered elastic drop-in bounce, 3D perspective mouse reaction, and zero progress bars.
* **Screen 2 — Stage Spotlight & Orbital Carousel:** An inflatable vinyl title deck, 3:4 proportional 3D squircle toy cards, specification capsule pills, and a monumental Glacial Mint (`#DDF8FA`) **`PLAY!`** trigger button.
* **Screen 3 — The Wine Toy-Lab:** An interactive graphics laboratory featuring an Apple Silicon M2 Pro telemetry dial, a **4-Way Mechanical Rotary Engine Selector** (DXMT, D3DMetal GPTK 2.0, DXVK, WineD3D), and three **Bulbous Cartoon Chemistry Flasks** with animated bubbling liquids.
* **Floating Console Dock:** Anchored bottom console dock providing instant tactile navigation between *Playground*, *Stores & Loot*, *Wine Toy-Lab*, and *Activity Logs*.
* **Minimalist Line Vector Glyphs:** 1.5px constant-width vector glyphs with rounded terminal caps. Zero platform emojis and zero generic HUD tropes.

---

## 🚀 Features

* **Multi-Store Gaming Ecosystem:**
  * **Steam** — Isolated bottle setup and automatic client launch recipe.
  * **Epic Games** — Integrated [Legendary](https://github.com/derrod/legendary) CLI integration with in-app authentication, store cover sync, and one-click installation.
  * **GOG Galaxy** — DRM-free offline installers in dedicated prefixes.
  * **Amazon Prime Games & Itch.io** — Built-in store browsing and DRM-free package execution.
* **Standalone Windows Executables:** Run any `.exe`, `.msi`, or `.bat` file with automatic prefix routing.
* **Direct Translation Engines:**
  * **DXMT** — DirectX 10/11 translated directly to Metal.
  * **D3DMetal (Apple GPTK 2.0)** — DirectX 11/12 execution via Apple's Game Porting Toolkit.
  * **DXVK + MoltenVK** — DirectX translated to Vulkan and bridged to Metal.
  * **WineD3D** — DirectX mapped to OpenGL.
* **Controller Ready:** Native Apple Game Controller framework support with real-time DualSense, Xbox, and MFi status indicators.
* **Shader Cache & Save Safeguards:** Automatic prefix shader purging and timestamped save-game backup archives.

---

## 💻 System Requirements

* **Hardware:** Mac with Apple Silicon (M1, M2, M3, M4 or later).
* **Operating System:** macOS 14 Sonoma or macOS 15 Sequoia.
* **Rosetta 2:** Required for Intel binary translation.
* **Display:** Optimized for Liquid Retina XDR displays (including 120Hz ProMotion).

---

## 🛠️ Build & Run from Source

To compile and build ArcWicky locally:

```bash
# 1. Clone the repository
git clone https://github.com/oscarlaradev/ArcWicky.git
cd ArcWicky

# 2. Run the build script (executes all 297 unit tests and packages the app)
./build.sh

# 3. Launch the application
open ArcWicky.app
```

To create a clean macOS disk image (`.dmg`):

```bash
./scripts/make-dmg.sh
```

---

## 📁 Architecture & Directories

ArcWicky organizes prefixes and configurations inside the user space:

```
~/Library/Application Support/ArcWicky/
├── engines/     # Wine binaries, GPTK libraries, and Legendary CLI
├── bottles/     # Isolated Wine prefixes (Steam, Epic, Custom)
└── cache/       # Downsampled artwork and downloaded installers
```

---

## 📜 License & Credits

ArcWicky is open-source software licensed under the **[MIT License](LICENSE)**.

Third-party translation components and dependencies:
* **Wine / Wine Staging** — LGPL 2.1+ ([WineHQ](https://www.winehq.org/))
* **DXMT** — LGPL 2.1+ ([3Shain/dxmt](https://github.com/3Shain/dxmt))
* **DXVK-macOS** — Zlib ([Gcenx/DXVK-macOS](https://github.com/Gcenx/DXVK-macOS))
* **MoltenVK** — Apache 2.0 ([KhronosGroup/MoltenVK](https://github.com/KhronosGroup/MoltenVK))
* **Legendary** — GPLv3 ([derrod/legendary](https://github.com/derrod/legendary))
* **Epilogue & Fredoka** — SIL Open Font License (OFL)

---

<p align="center">Designed with the <em>Tactile Vinyl & Spatial Cartoon</em> philosophy.</p>
