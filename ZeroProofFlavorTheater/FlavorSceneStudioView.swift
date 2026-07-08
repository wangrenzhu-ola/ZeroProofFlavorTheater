import SwiftUI

struct FlavorSceneStudioView: View {
    @EnvironmentObject private var store: FlavorSceneStore
    @Binding var path: [AppRoute]
    @State private var draft: FlavorSceneDraft
    @State private var showSuggestionSheet = false
    @State private var localError: String?
    @State private var savedRecordID: UUID?

    init(path: Binding<[AppRoute]>, initialDraft: FlavorSceneDraft) {
        _path = path
        _draft = State(initialValue: initialDraft)
    }

    var body: some View {
        Form {
            if let localError {
                Section { ErrorBanner(message: localError, retry: save) }
            }
            Section("Flavor Scene identity") {
                TextField("Flavor Scene name", text: $draft.title)
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("Flavor Scene name")
                Picker("Drink stage", selection: $draft.flavorStage) {
                    ForEach(FlavorStage.allCases) { Text($0.rawValue).tag($0) }
                }
                FlavorSceneGlass(stage: draft.flavorStage, cue: previewCue)
                    .frame(height: 150)
                    .accessibilityLabel("Miniature flavor scene preview")
            }
            Section("Flavor cue") {
                Picker("Tasting mode", selection: $draft.readingMode) {
                    ForEach(ReadingMode.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                if draft.readingMode == .tested {
                    Stepper("Sweetness: \(draft.sweetness, specifier: "%.0f")", value: $draft.sweetness, in: 0...10, step: 1)
                    Stepper("Tartness: \(draft.tartness, specifier: "%.0f")", value: $draft.tartness, in: 0...10, step: 1)
                    Stepper("Bitterness: \(draft.bitterness, specifier: "%.0f")", value: $draft.bitterness, in: 0...10, step: 1)
                } else {
                    Text("Manual not-tasted state keeps the Flavor Scene usable and reminds you to retaste before serving.")
                }
            }
            Section("Living-scene observation") {
                Picker("Observation", selection: $draft.observation) {
                    ForEach(ObservationType.allCases) { Text($0.rawValue).tag($0) }
                }
                TextEditor(text: $draft.careNote)
                    .frame(minHeight: 96)
                    .accessibilityLabel("Flavor Scene note")
                Button("Optional editable note cleanup") { showSuggestionSheet = true }
                    .accessibilityLabel("Open optional AI/manual fallback suggestion")
            }
            Section("Cue preview") {
                let preview = FlavorSceneEngine.evaluate(draft, previous: store.records.first)
                CuePill(cue: preview.cue, reason: preview.reason)
                Text(preview.comparison).font(.footnote).foregroundStyle(.secondary)
            }
            Section {
                Button("Save this Flavor Scene.", action: save)
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Save this Flavor Scene")
                Button("Simulate save failure for recovery") { store.simulateNextSaveFailure = true; save() }
                    .accessibilityLabel("Simulate Flavor Scene save failure")
            }
        }
        .navigationTitle(draft.id == nil ? "Flavor Scene Studio" : "Review your Flavor Scene changes.")
        .sheet(isPresented: $showSuggestionSheet) { SuggestionSheet(draft: $draft) }
        .onDisappear { store.draft = draft }
    }

    private var previewCue: FlavorCue { FlavorSceneEngine.evaluate(draft, previous: store.records.first).cue }

    private func save() {
        do {
            let record = try store.save(draft)
            savedRecordID = record.id
            localError = nil
            path.append(.detail(record.id))
        } catch {
            localError = error.localizedDescription
        }
    }
}

private struct SuggestionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var draft: FlavorSceneDraft

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("AI unavailable or declined? Manual flow still works.").font(.title2.bold())
                Text("This local suggestion is editable and skipped unless you tap Apply. No factory Kimi key, secret, or autonomous save is used.")
                Text(FlavorSceneEngine.aiFallbackNote(for: draft)).padding().background(Color(hex: "EAF7F3"), in: RoundedRectangle(cornerRadius: 18))
                Spacer()
                Button("Apply editable note") { draft.careNote = FlavorSceneEngine.aiFallbackNote(for: draft); dismiss() }
                    .buttonStyle(.borderedProminent)
                Button("Keep manual note") { dismiss() }
            }
            .padding()
            .navigationTitle("Manual fallback")
        }
    }
}
