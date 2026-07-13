import SwiftUI

@main
struct TwinkoApp: App {
    var body: some Scene {
        WindowGroup {
            RootRouterView()
                // Traditional Chinese first (D-054); English localization
                // is deferred, so the prototype pins its locale.
                .environment(\.locale, Locale(identifier: "zh-Hant"))
        }
    }
}
