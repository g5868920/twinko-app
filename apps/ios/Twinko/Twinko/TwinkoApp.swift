import SwiftUI

@main
struct TwinkoApp: App {
    init() {
        // Local development/UI-test hooks. These touch only this
        // prototype's local JSON files.
        let arguments = CommandLine.arguments
        if arguments.contains("-uiTestReset") {
            let store = JSONStore()
            store.delete("profile")
            store.delete("chat_sessions")
            store.delete("prefs")
        }
        if arguments.contains("-uiTestSeedProfile") {
            let store = JSONStore()
            let birthday = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? .now
            store.save(UserProfile(preferredName: "小雅", birthday: birthday,
                                   gender: .preferNotToSay), as: "profile")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootRouterView()
            // Locale is applied inside RootRouterView from the persisted
            // language preference (Traditional Chinese by default).
        }
    }
}
