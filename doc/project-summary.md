# SymbolPad – Project Summary

## What it is
A minimal symbol copy-pad — click a symbol to copy it to clipboard. Built as a single HTML file that runs in the browser, and wrapped in Tauri 2 to run as a native menubar tray app on macOS (working) and Windows (planned).

The app lives in the macOS menu bar — no dock icon. Clicking the tray icon toggles the panel open/closed.

---

## Current symbols
| Symbol | Label |
|--------|-------|
| – | En dash |
| ' | Single open quote |
| ' | Single close quote |
| „ | Double low quote |
| " | Double close quote |
| ¡ | Inverted exclamation |
| → | Right arrow |
| ≤ | Less or equal |

---

## Features
- Click a card to copy its symbol to clipboard (with fallback for restricted contexts)
- Drag-to-reorder via **pointer events** (not HTML5 drag API — Tauri intercepts those on macOS)
- Edit mode: entered via tray right-click menu or Edit button; exited via Done, Esc, clicking grid background, or closing panel
  - Add new symbols via modal
  - Delete existing ones with × badge
- Dark mode: follows system preference; falls back to local sunrise/sunset via geolocation; manual override via ☀️/🌙 button
- Theme submenu in tray right-click menu: System Auto / Light / Dark with live `CheckMenuItem` checkmarks
- Blur-to-hide with 300ms debounce (prevents immediately closing after opening)
- Panel expands vertically with animation when symbols are added (no scrolling)
- Clean, minimal design with serif symbol rendering (Georgia)
- In macOS app context (`window.__TAURI_INTERNALS__` check): title bar, theme button, and edit button are hidden (controlled via tray menu instead)

---

## File overview

| File | Purpose |
|------|---------|
| `src/index.html` | The entire front-end app — single source of truth |
| `src-tauri/src/main.rs` | Rust: tray icon, popover window, right-click menu, blur-to-hide, Rust→JS bridge |
| `src-tauri/tauri.conf.json` | Tauri config: window 500×320, decorations off, alwaysOnTop |
| `src-tauri/Info.plist` | macOS: `LSUIElement=true` — hides dock icon |
| `src-tauri/Cargo.toml` | Rust dependencies (tauri, tauri-plugin-positioner) |
| `src-tauri/build.rs` | Required tauri-build call |
| `package.json` | Node scripts: dev, build, web |
| `.github/workflows/build.yml` | CI: builds .dmg (macOS universal) + .exe (Windows) on push to main |
| `src-tauri/icons/tray.png` | Tray icon: pure black 32×32, template image |
| `src-tauri/icons/icon.png` | App icon: 1024×1024 |
| `resources/icons/tray.svg` | SVG source for tray icon (32×32) |
| `resources/icons/app-icon.svg` | SVG source for app icon (1024×1024) |
| `doc/project-summary.md` | This file — living reference across sessions |

---

## Icon design
- **Shape:** Guillemet chevron (›) as a cutout from a rounded square
- **Tray icon path:** `d="M737,196l-38-71h30l53,71-53,72H699"` with `transform="translate(-125 274)"`
- **Tray icon:** pure black on transparent, `icon_as_template(true)` for macOS auto-inversion (dark/light menubar)
- **Sources:** `resources/icons/tray.svg` (32×32) and `resources/icons/app-icon.svg` (1024×1024)
- **Convert:** `rsvg-convert` for SVG→PNG, then `npm run tauri icon` for full icon set

---

## Rust→JS bridge
Rust calls into the frontend via `window.eval()`:
- `eval("enterEditMode()")` — triggered from tray menu "Edit Symbols"
- `eval("exitEditMode()")` — triggered from tray menu "Done Editing"
- `eval("setTheme(mode)")` — triggered from Theme submenu (values: `"system"`, `"light"`, `"dark"`)

---

## Build targets
| Target | How |
|--------|-----|
| Web | Open `src/index.html` in any browser |
| Dev | `npm run dev` (live reload) |
| macOS `.dmg` | Push to `main` → GitHub Actions builds universal binary (Intel + Apple Silicon) |
| Windows `.exe` / `.msi` | Push to `main` → GitHub Actions builds it |

---

## Todo
- [ ] UI/design polish of the macOS panel (next priority):
  - Rounded corners and shadow on the panel window itself
  - Smoother open/close animation
  - Card spacing and sizing refinement
  - Window position fine-tuning (currently `TrayCenter`)
- [ ] Expand panel for additional symbol categories
- [ ] Windows: implement and verify tray behaviour
- [ ] Code-sign and notarize for distribution (removes need for xattr workaround)

---

## Key learnings & gotchas
- `TrayIconEvent::Click` fires twice (mouse down + up) — match on `MouseButtonState::Up` to prevent double-firing
- HTML5 drag API is intercepted by Tauri on macOS — use pointer events for drag-to-reorder
- macOS tray icon must be **pure black pixels on transparent background** — any grey causes invisible rendering in light menubar
- `include_bytes!` required for bundled assets — runtime-relative paths fail in packaged apps
- Tauri 2 `Info.plist` expects a file path, not an inline object; `info` is not a valid key in `tauri.conf.json`
- macOS Gatekeeper quarantine silently blocks unsigned apps — remove with `xattr -dr com.apple.quarantine /Applications/SymbolPad.app`
- macOS Sequoia hides third-party tray icons by default — enable via System Settings → Control Center → SymbolPad
- Blur-to-hide needs a debounce (300ms) — focus briefly flickers when the window first appears

---

## Useful commands
```bash
# Clean restart after fresh install
killall SymbolPad; sleep 0.5; xattr -dr com.apple.quarantine /Applications/SymbolPad.app && open /Applications/SymbolPad.app

# Convert SVG → PNG (requires rsvg-convert)
rsvg-convert -w 32 -h 32 resources/icons/tray.svg -o src-tauri/icons/tray.png
rsvg-convert -w 1024 -h 1024 resources/icons/app-icon.svg -o src-tauri/icons/icon.png

# Generate full icon set from icon.png
npm run tauri icon src-tauri/icons/icon.png

# Push to trigger CI build
git add . && git commit -m "build" && git push
```

---

## Notes
- All visual/symbol changes go in `src/index.html` only
- GitHub Actions produces a **draft release** — review before publishing
- Version is currently at `0.2.0`
