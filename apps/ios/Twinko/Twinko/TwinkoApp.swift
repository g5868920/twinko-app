import SwiftUI

@main
struct TwinkoApp: App {
    init() {
        // Local development/UI-test hook: start from a clean prototype
        // state. Deletes only this prototype's local JSON files.
        if CommandLine.arguments.contains("-uiTestReset") {
            let store = JSONStore()
            store.delete("profile")
            store.delete("chat_sessions")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootRouterView()
                // Traditional Chinese first (D-054); English localization
                // is deferred, so the prototype pins its locale.
                .environment(\.locale, Locale(identifier: "zh-Hant"))
        }
    }
}
