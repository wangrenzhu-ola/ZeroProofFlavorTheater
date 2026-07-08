import SwiftUI

@main
struct ZeroProofFlavorTheaterApp: App {
    @StateObject private var store = FlavorSceneStore()
    @StateObject private var premiumStore = PremiumStore()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(store)
                .environmentObject(premiumStore)
        }
    }
}
