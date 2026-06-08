import AppKit
import ServiceManagement
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var popover: NSPopover!

    let store = SymbolStore()
    let appState = AppState()

    @AppStorage("theme") var theme: AppTheme = .system

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView()
                .environmentObject(store)
                .environmentObject(appState)
        )

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            if let icon = NSImage(named: "tray") {
                icon.isTemplate = true
                icon.size = NSSize(width: 18, height: 18)
                button.image = icon
            }
            button.action = #selector(handleClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    // MARK: - Click handling

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            popover.isShown ? popover.performClose(nil) : showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        applyTheme()
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Context menu

    private func showContextMenu() {
        let menu = NSMenu()

        let editTitle = appState.editMode ? "Stop editing" : "Edit symbols"
        menu.addItem(NSMenuItem(title: editTitle, action: #selector(toggleEditMode), keyEquivalent: ""))

        let themeMenu = NSMenu()
        themeMenu.addItem(checkItem(title: "System", current: theme == .system, action: #selector(setThemeSystem)))
        themeMenu.addItem(checkItem(title: "Light",  current: theme == .light,  action: #selector(setThemeLight)))
        themeMenu.addItem(checkItem(title: "Dark",   current: theme == .dark,   action: #selector(setThemeDark)))
        let themeItem = NSMenuItem(title: "Theme", action: nil, keyEquivalent: "")
        themeItem.submenu = themeMenu
        menu.addItem(themeItem)

        menu.addItem(.separator())
        menu.addItem(checkItem(title: "Launch at Login", current: launchAtLoginEnabled, action: #selector(toggleLaunchAtLogin)))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Symbol Pad", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    private func checkItem(title: String, current: Bool, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.state = current ? .on : .off
        return item
    }

    // MARK: - Actions

    @objc private func toggleEditMode() {
        if !popover.isShown { showPopover() }
        appState.editMode.toggle()
    }

    private var launchAtLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            if launchAtLoginEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSLog("Launch at login toggle failed: \(error)")
        }
    }

    @objc private func setThemeSystem() { theme = .system; applyTheme() }
    @objc private func setThemeLight()  { theme = .light;  applyTheme() }
    @objc private func setThemeDark()   { theme = .dark;   applyTheme() }

    private func applyTheme() {
        switch theme {
        case .system: NSApp.appearance = nil
        case .light:  NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:   NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}
