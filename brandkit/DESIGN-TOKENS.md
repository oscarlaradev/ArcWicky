# ArcWicky — Design Tokens & UI Spec (v2)

> Design system specification for ArcWicky. Synthesizes the kinetic joy of modern animation and designer vinyl toys with the pristine spatial balance of high-end interfaces. Built on the **Polar Fusion** color system and **Tactile Vinyl & Spatial Cartoon** philosophy.

## 1. Brand Context

**ArcWicky** is a free, open-source macOS app built with SwiftUI that installs, configures, and launches Windows games through Wine and Metal translation on Apple Silicon.

### Hard Rules

| # | Rule |
|---|---|
| R1 | UI follows the **Polar Fusion** palette. Deep velvet midnight void with physical specular vinyl highlights. |
| R2 | Never use generic platform emojis or razor-sharp cyberpunk sci-fi tropes. Iconography uses 1.5px constant-width rounded vector glyphs. |
| R3 | No branding or app logos in the top-left corner of the main window. Branding lives organically in living sculptural objects. |
| R4 | Every interactive card and container carries a minimum 24px–32px squircle radius and 1.5px structural border (`#303B59`). |
| R5 | Buttons feature 3D vinyl extrusion shadows (`0 8px 0 #50696b` or `0 8px 0 #070e1f`) with tactile hover elevation and active press depression. |
| R6 | Zero generic loading spinners. Progress is visualized as kinetic bubbling cartoon liquid or swelling vinyl segments. |

---

## 2. Polar Fusion Color Tokens

The palette operates on an ultra-deep, velvety night canvas paired with high-specular vinyl highlights.

| Token | Hex | Role |
|---|---|---|
| **Canvas Void** | `#090B11` | Root foundational background. Absorbs ambient scatter. |
| **Vignette Floor** | `#111725` | Radial and vertical atmospheric gradients. |
| **Chunky Deep Slate** | `#171E30` | Recessed panels, navigation tracks, foundation trays. |
| **Muted Navy Container** | `#202A42` | Primary tactile layer for cards, pods, and raised surfaces. |
| **Structural Boundary** | `#303B59` | Mandatory 1.5px continuous outline for cards and partitions. |
| **Crisp Specular** | `#DCE8FF` | Puffy typography, primary keylines, rim highlights. |
| **Glacial Mint** | `#DDF8FA` | High-energy focal triggers, live status orbs, toggled pills, `PLAY!` button. |
| **Primary Container** | `#CDE8EA` | Active toggle container, primary action base. |
| **Ambient Violet Mist** | `#F0EAFE` | Diffuse atmospheric backdrops and secondary edge glows. |

---

## 3. Typography Spec

* **Primary Font:** Epilogue (geometric, chunky, rounded letterforms).
* **Headlines:** Epilogue 800 (ExtraBold) with tight negative tracking (`-0.02em` to `-0.03em`) for snug, pillowy lockups.
* **Micro-rotations:** Static `-1.5°` to `+1.5°` micro-rotations on hero badges and titles to impart cartoon cadence.
* **Body Text:** Epilogue 500 (Medium) for high legibility against velvety dark backings.

---

## 4. Elevation & Shadow Physics

1. **Recessed Canvas (Level 0):** `#090B11` to `#111725`. Zero elevation.
2. **Floor Plates & Trays (Level 1):** `#171E30` bounded by 1.5px outline in `#303B59`. Dense toy shadow: `0 8px 0 #090B11`.
3. **Floating Toy Blocks & Cards (Level 2):** `#202A42` with interior top rim highlight (`inset 0 2px 0 rgba(220, 232, 255, 0.15)`) and exterior drop shadow (`0 12px 0 #070E1F, 0 20px 28px rgba(0, 0, 0, 0.4)`).
4. **Hero Action Droplets & Live Triggers (Level 3):** `#DDF8FA` with extruded underside (`0 8px 0 #50696B`) and ambient mist halo (`0 0 24px rgba(240, 234, 254, 0.18)`).
