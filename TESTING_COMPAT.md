# Testing Compatibility Reports

## Build Modes & Debug Features

### Release Build (Production)
The standard `./build.sh` creates a release build and signed app bundle:

```bash
./build.sh
# Creates ArcWicky.app in the repository root
```

### Debug Build
For development with debug symbols:

```bash
swift build -c debug
# Binary: .build/debug/ArcWicky
```

Both release and debug builds support:
- `arcwicky.compat.debugJsonPath` / `vermut.compat.debugJsonPath` UserDefaults override
- `ARCWICKY_DEBUG_FEEDBACK=1` / `VERMUT_DEBUG_FEEDBACK=1` environment variable

---

## QA Testing

### Test with a Local JSON File

Works in **both debug and release builds**:

1. Create a test compatibility JSON file:
```bash
cat > /tmp/test-compat.json << 'EOF'
{
  "games": [
    {
      "store": "steam",
      "gameId": "620",
      "gameName": "Portal 2",
      "byGraphics": {
        "dxmt": { "perfect": 42, "issues": 3, "broken": 1 },
        "dxvk": { "perfect": 12, "issues": 5, "broken": 0 }
      },
      "recommended": "dxmt",
      "totalReports": 63
    }
  ],
  "generated": 1730000000,
  "reportCount": 63
}
EOF
```

2. Configure ArcWicky to use it:
```bash
defaults write com.opensource.arcwicky vermut.compat.debugJsonPath "/tmp/test-compat.json"
```

3. Launch ArcWicky and check Library:
```bash
open ArcWicky.app
```

### Clear Debug Settings

```bash
defaults delete com.opensource.arcwicky vermut.compat.debugJsonPath
```

---

## Running Builds

### Release Build
```bash
# Standard release build
./build.sh

# Launch normally
open ArcWicky.app
```

### Debug Build
```bash
# Build
swift build -c debug

# Launch
.build/debug/ArcWicky
```
