import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: FlavorSceneStore
    @EnvironmentObject private var premium: PremiumStore
    @Binding var path: [AppRoute]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HeroFlavorStage(cue: store.records.first?.cue ?? .watch, title: "ZeroProof", subtitle: store.latestComparison)
                    .accessibilityLabel("Miniature flavor scene with water cue color and saved Flavor Scene comparison")

                if store.records.isEmpty {
                    EmptyFlavorSceneView(create: startFlavorScene)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Flavor Scenes").font(.title2.bold())
                        ForEach(store.records) { record in
                            Button { path.append(.detail(record.id)) } label: { FlavorSceneCard(record: record) }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Open Flavor Scene \(record.title), cue \(record.cue.rawValue)")
                        }
                    }
                }

                PremiumPreviewCard(isUnlocked: premium.isPremiumUnlocked) { path.append(.paywall) }
                Button("Start your first Flavor Scene.", action: startFlavorScene)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityLabel("Start your first Flavor Scene")
                Button("Privacy and AI boundary") { path.append(.privacy) }
                    .accessibilityLabel("Open Privacy and AI boundary sheet")
            }
            .padding()
        }
        .navigationTitle("Flavor Scenes")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("New") { startFlavorScene() } } }
        .task { await premium.loadProducts() }
    }

    private func startFlavorScene() {
        store.startNewDraft()
        path.append(.studio(.blank))
    }
}

private struct EmptyFlavorSceneView: View {
    let create: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Start your first Flavor Scene.").font(.title2.bold())
            Text("Log a flavor scene, water readings, and one living-scene observation. ZeroProof will render Stable, Watch, or Intervene without making veterinary claims.")
            MiniCueComparison(newText: "No saved cue yet", previousText: "Comparison appears after your first save")
            Button("Create Flavor Scene", action: create).buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: .combine)
    }
}
