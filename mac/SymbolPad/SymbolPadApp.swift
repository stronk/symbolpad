import SwiftUI

@main
struct SymbolPadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        // Empty settings scene keeps the app alive without a dock icon or window
        Settings { EmptyView() }
    }
}
