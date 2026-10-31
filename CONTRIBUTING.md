# Contributing to ArcWicky

Thanks for helping. ArcWicky is a native macOS app built with SwiftUI on top of a modular, testable core library.

## Reporting Issues

1. Search existing issues before creating a new report.
2. When submitting a new issue, include:
   - macOS version and Apple Silicon processor model (e.g., M1, M2 Pro, M3 Max)
   - ArcWicky version
   - Reproduction steps
   - Expected vs. actual behavior
   - Redacted output from **Settings → Copy diagnostic report**

## Development & Pull Requests

```bash
# Clone and run unit tests
git clone https://github.com/oscarlaradev/ArcWicky.git
cd ArcWicky
swift test

# Build the release app bundle and run smoke tests
./build.sh
```

### Guidelines

- Maintain product naming as **ArcWicky**. Swift package targets remain `CaskLauncherCore` / `CaskLauncherApp`.
- Follow the **Tactile Vinyl & Spatial Cartoon** design system:
  - 3D extruded vinyl buttons with physical drop shadows (`0 8px 0 #070e1f` or variant).
  - Heavy squircle contours (24px to 32px radii).
  - Minimalist 1.5px constant-width vector glyphs.
  - Strictly avoid generic platform emojis or cyberpunk tropes.
- Place shared business logic in `Sources/CaskLauncherCore` accompanied by unit tests. Keep views and presentation logic in `Sources/CaskLauncherApp`.
- Test builds locally on Apple Silicon with `./build.sh` to ensure all 297 unit tests pass and code signature verifies.

## Code of Conduct

Be respectful and collaborative. We are committed to providing a friendly, safe, and welcoming environment for all contributors.

## License

Contributions are accepted under the MIT License detailed in [LICENSE](LICENSE).
