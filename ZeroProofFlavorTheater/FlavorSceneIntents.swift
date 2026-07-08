import AppIntents
import Foundation

struct DraftFlavorSceneIntent: AppIntent {
    static var title: LocalizedStringResource = "Draft Flavor Scene"
    static var description = IntentDescription("Creates an editable ZeroProof Flavor Scene draft title and opens the app. It never saves autonomously.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Flavor Scene Title") var title: String

    init() { self.title = "" }
    init(title: String) { self.title = title }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        UserDefaults.standard.set(title, forKey: "pendingFlavorSceneTitle")
        return .result(dialog: "Editable Flavor Scene draft ready. Review it before saving.")
    }
}

struct ZeroProofShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: DraftFlavorSceneIntent(), phrases: ["Draft a \(.applicationName) flavor scene"], shortTitle: "Draft Flavor Scene", systemImageName: "water.waves")
    }
}
