import Foundation
import Combine

@MainActor
final class FlavorSceneStore: ObservableObject {
    @Published private(set) var records: [FlavorSceneRecord] = []
    @Published var draft: FlavorSceneDraft = .blank { didSet { persistDraft() } }
    @Published var privacyChoice = PrivacyChoice() { didSet { persistPrivacy() } }
    @Published var lastErrorMessage: String?
    @Published var lastSuccessMessage: String?
    @Published var simulateNextSaveFailure = false

    private let recordsURL: URL
    private let draftKey = "ZeroProofFlavorTheater.draft"
    private let privacyKey = "ZeroProofFlavorTheater.privacy"

    init(fileManager: FileManager = .default) {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        recordsURL = docs.appendingPathComponent("zeroproof-care-scenes.json")
        load()
    }

    var latestComparison: String {
        guard let newest = records.first else { return "No saved comparison yet. Save the first Flavor Scene to start a local history." }
        return FlavorSceneEngine.comparisonCopy(newCue: newest.cue, previous: records.dropFirst().first)
    }

    func startNewDraft() { draft = .blank }

    func applyOptionalSuggestion() {
        draft.careNote = FlavorSceneEngine.aiFallbackNote(for: draft)
    }

    @discardableResult
    func save(_ incoming: FlavorSceneDraft) throws -> FlavorSceneRecord {
        guard !incoming.trimmedTitle.isEmpty else { throw FlavorSceneSaveError.emptyTitle }
        if simulateNextSaveFailure {
            simulateNextSaveFailure = false
            lastErrorMessage = FlavorSceneSaveError.simulatedFailure.localizedDescription
            throw FlavorSceneSaveError.simulatedFailure
        }
        let previous = records.first(where: { $0.id != incoming.id })
        let evaluation = FlavorSceneEngine.evaluate(incoming, previous: previous)
        let now = Date()
        let record = FlavorSceneRecord(
            id: incoming.id ?? UUID(),
            title: incoming.trimmedTitle,
            flavorStage: incoming.flavorStage,
            readingMode: incoming.readingMode,
            sweetness: incoming.sweetness,
            tartness: incoming.tartness,
            bitterness: incoming.bitterness,
            observation: incoming.observation,
            careNote: incoming.careNote,
            cue: evaluation.cue,
            cueReason: evaluation.reason,
            waterCueHex: evaluation.waterHex,
            createdAt: records.first(where: { $0.id == incoming.id })?.createdAt ?? now,
            updatedAt: now
        )
        if let index = records.firstIndex(where: { $0.id == record.id }) { records[index] = record } else { records.insert(record, at: 0) }
        records.sort { $0.updatedAt > $1.updatedAt }
        draft = FlavorSceneDraft(record: record)
        do { try persistRecords() } catch { throw FlavorSceneSaveError.storageFailure(error.localizedDescription) }
        lastErrorMessage = nil
        lastSuccessMessage = "Flavor Scene saved."
        return record
    }

    func delete(_ record: FlavorSceneRecord) {
        records.removeAll { $0.id == record.id }
        try? persistRecords()
    }

    func exportText(for record: FlavorSceneRecord) -> String {
        "\(record.title) — \(record.cue.rawValue): \(record.cueReason)"
    }

    private func load() {
        if let data = try? Data(contentsOf: recordsURL), let decoded = try? JSONDecoder.drinkTheater.decode([FlavorSceneRecord].self, from: data) { records = decoded.sorted { $0.updatedAt > $1.updatedAt } }
        if let data = UserDefaults.standard.data(forKey: draftKey), let decoded = try? JSONDecoder.drinkTheater.decode(FlavorSceneDraft.self, from: data) { draft = decoded }
        if let data = UserDefaults.standard.data(forKey: privacyKey), let decoded = try? JSONDecoder.drinkTheater.decode(PrivacyChoice.self, from: data) { privacyChoice = decoded }
        if let pending = UserDefaults.standard.string(forKey: "pendingFlavorSceneTitle"), !pending.isEmpty {
            draft.title = pending
            UserDefaults.standard.removeObject(forKey: "pendingFlavorSceneTitle")
        }
    }

    private func persistRecords() throws {
        let data = try JSONEncoder.drinkTheater.encode(records)
        try data.write(to: recordsURL, options: [.atomic])
    }

    private func persistDraft() {
        if let data = try? JSONEncoder.drinkTheater.encode(draft) { UserDefaults.standard.set(data, forKey: draftKey) }
    }

    private func persistPrivacy() {
        if let data = try? JSONEncoder.drinkTheater.encode(privacyChoice) { UserDefaults.standard.set(data, forKey: privacyKey) }
    }
}

struct PrivacyChoice: Codable, Hashable {
    var optionalAIRoutingAllowed = false
    var seedExamplesVisible = true
    var localExportAllowed = true
}

extension JSONEncoder {
    static var drinkTheater: JSONEncoder { let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601; return encoder }
}

extension JSONDecoder {
    static var drinkTheater: JSONDecoder { let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601; return decoder }
}
