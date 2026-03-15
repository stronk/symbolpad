# SymbolPad – Project Summary

## What it is
A minimal symbol copy-pad — click a symbol to copy it to clipboard. Built as a single HTML file that runs in the browser, and wrapped in Tauri to run as a native menubar tray app on macOS and Windows.

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

---

## Features
- Click a card to copy its symbol to clipboard (with fallback for restricted contexts)
- Drag and drop cards to reorder
- Edit mode (toggle): add new symbols via modal, delete existing ones with × badge
- Dark mode: follows system preference; falls back to local sunrise/sunset via geolocation; manual override via ☀️/🌙 button
- Clean, minimal design with serif symbol rendering (Georgia)

---

## File overview

| File | Purpose |
|------|---------|
| `src/index.html` | The entire front-end app — single source of truth |
| `src-tauri/src/main.rs` | Rust: tray icon, popover window, blur-to-hide |
| `src-tauri/tauri.conf.json` | Tauri config: window size, app name, identifier |
| `src-tauri/Cargo.toml` | Rust dependencies (tauri, tauri-plugin-positioner) |
| `package.json` | Node scripts: dev, build, web |
| `.github/workflows/build.yml` | CI: builds .dmg (macOS universal) + .exe (Windows) on push to main |
| `src-tauri/icons/tray.svg` | Tray icon: square keycap with „ cutout, 32×32 |
| `src-tauri/icons/app-icon.svg` | App icon: same design, 1024×1024 — convert to icon.png |

---

## Build targets
| Target | How |
|--------|-----|
| Web | Open `src/index.html` in any browser |
| Dev | `npm run dev` (live reload) |
| macOS `.dmg` | Push to `main` → GitHub Actions builds it |
| Windows `.exe` / `.msi` | Push to `main` → GitHub Actions builds it |

---

## Pending
- Convert `tray.svg` → `tray.png` (32×32)
- Convert `app-icon.svg` → `icon.png` (1024×1024)
- Create GitHub repo and push files
- Download built `.dmg` and `.exe` from GitHub Releases

---

## Notes
- All visual/symbol changes go in `src/index.html` only
- macOS tray icon uses `icon_as_template: true` — OS auto-inverts for dark/light menubar
- GitHub Actions produces a **draft release** — review before publishing
- macOS build is a universal binary (Intel + Apple Silicon)
