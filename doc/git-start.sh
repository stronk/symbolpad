# 1. Install Git if you don't have it yet
#    Download from https://git-scm.com and install, then come back here.
#    (Check if you already have it with:)
git --version

# 2. Create the project folder and go into it
#mkdir symbolpad
#cd symbolpad

# 3. Create the folder structure
#mkdir -p src src-tauri/src src-tauri/icons .github/workflows

# 4. Copy your files into place:
#    - Save the Symbol Pad artifact as:        src/index.html
#    - Save the Project Guide artifact as:     (reference only, not a project file)
#    - Save the GitHub Actions artifact as:    .github/workflows/build.yml
#    - Save the main.rs artifact as:           src-tauri/src/main.rs
#    - Save the tray icon SVG as:              src-tauri/icons/tray.svg
#    Then convert tray.svg → tray.png (32×32) and place it at src-tauri/icons/tray.png
#    Add a 1024×1024 icon.png at:             src-tauri/icons/icon.png

# 5. Create the Cargo.toml
cat > src-tauri/Cargo.toml << 'EOF'
[package]
name = "symbol-pad"
version = "0.1.0"
edition = "2021"

[dependencies]
tauri = { version = "2", features = ["tray-icon", "image-png"] }
tauri-plugin-positioner = { version = "2", features = ["tray-icon"] }

[features]
default = ["custom-protocol"]
custom-protocol = ["tauri/custom-protocol"]
EOF

# 6. Create tauri.conf.json
cat > src-tauri/tauri.conf.json << 'EOF'
{
  "productName": "SymbolPad",
  "version": "0.1.0",
  "identifier": "com.symbolpad.app",
  "build": {
    "frontendDist": "../src"
  },
  "app": {
    "windows": [
      {
        "label": "main",
        "title": "Symbol Pad",
        "width": 500,
        "height": 280,
        "decorations": false,
        "alwaysOnTop": true,
        "visible": false,
        "resizable": false,
        "skipTaskbar": true,
        "shadow": true
      }
    ]
  },
  "bundle": {
    "active": true,
    "targets": "all",
    "icon": ["icons/icon.png"]
  }
}
EOF

# 7. Create package.json
cat > package.json << 'EOF'
{
  "name": "symbol-pad",
  "version": "0.1.0",
  "scripts": {
    "dev": "tauri dev",
    "build": "tauri build",
    "web": "npx serve src -l 3000"
  },
  "devDependencies": {
    "@tauri-apps/cli": "^2.0.0"
  },
  "dependencies": {
    "@tauri-apps/api": "^2.0.0"
  }
}
EOF

# 8. Initialise a Git repository
git init
git add .
git commit -m "Initial commit"

# 9. Create a new repo on GitHub:
#    → Go to https://github.com/new
#    → Name it "symbolpad"
#    → Leave it empty (no README, no .gitignore)
#    → Click "Create repository"
#    → Copy the repo URL shown on the next page, looks like:
#       https://github.com/YOUR_USERNAME/symbolpad.git

# 10. Connect your local folder to GitHub and push
git remote add origin https://github.com/stronk/symbolpad.git
git branch -M main
git push -u origin main

# That's it! Go to:
# https://github.com/YOUR_USERNAME/symbolpad/actions
# You'll see the build running. When it finishes (≈10 min),
# go to the Releases tab to download your .dmg and .exe
