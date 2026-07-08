import Foundation
import SwiftUI

struct FlavorSceneRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var flavorStage: FlavorStage
    var readingMode: ReadingMode
    var sweetness: Double
    var tartness: Double
    var bitterness: Double
    var observation: ObservationType
    var careNote: String
    var cue: FlavorCue
    var cueReason: String
    var flavorCueHex: String
    var createdAt: Date
    var updatedAt: Date
}

enum FlavorStage: String, CaseIterable, Codable, Identifiable, Hashable {
    case citrusSpritz = "Citrus spritz"
    case spiceTonic = "Spice tonic"
    case gardenFizz = "Garden fizz"
    case bitterHighball = "Bitter highball"

    var id: String { rawValue }
    var accentHex: String {
        switch self {
        case .citrusSpritz: return "E9A43A"
        case .spiceTonic: return "B86B4B"
        case .gardenFizz: return "5F9F79"
        case .bitterHighball: return "48607A"
        }
    }
}

enum ReadingMode: String, CaseIterable, Codable, Identifiable, Hashable {
    case tested = "Mixed today"
    case notTested = "Not tested"
    var id: String { rawValue }
}

enum ObservationType: String, CaseIterable, Codable, Identifiable, Hashable {
    case guestLoved = "Guest loved it"
    case tooSweet = "Too sweet"
    case flatFinish = "Flat finish"
    case garnishMissing = "Garnish missing"
    case needsBite = "Needs bite"
    var id: String { rawValue }
}


enum FlavorCue: String, CaseIterable, Codable, Identifiable, Hashable {
    case stable = "Balanced"
    case watch = "Adjust"
    case intervene = "Remix"

    var id: String { rawValue }
    var color: Color {
        switch self {
        case .stable: return Color(hex: "2FA872")
        case .watch: return Color(hex: "D9911A")
        case .intervene: return Color(hex: "D9534F")
        }
    }
}

struct FlavorSceneDraft: Codable, Hashable {
    var id: UUID?
    var title: String
    var flavorStage: FlavorStage
    var readingMode: ReadingMode
    var sweetness: Double
    var tartness: Double
    var bitterness: Double
    var observation: ObservationType
    var careNote: String
    var lastGeneratedCue: FlavorCue?
    var lastGeneratedReason: String?

    static let blank = FlavorSceneDraft(
        id: nil,
        title: "",
        flavorStage: .citrusSpritz,
        readingMode: .tested,
        sweetness: 5.0,
        tartness: 4.0,
        bitterness: 2.0,
        observation: .guestLoved,
        careNote: "",
        lastGeneratedCue: nil,
        lastGeneratedReason: nil
    )

    init(record: FlavorSceneRecord) {
        id = record.id
        title = record.title
        flavorStage = record.flavorStage
        readingMode = record.readingMode
        sweetness = record.sweetness
        tartness = record.tartness
        bitterness = record.bitterness
        observation = record.observation
        careNote = record.careNote
        lastGeneratedCue = record.cue
        lastGeneratedReason = record.cueReason
    }

    init(id: UUID?, title: String, flavorStage: FlavorStage, readingMode: ReadingMode, sweetness: Double, tartness: Double, bitterness: Double, observation: ObservationType, careNote: String, lastGeneratedCue: FlavorCue?, lastGeneratedReason: String?) {
        self.id = id
        self.title = title
        self.flavorStage = flavorStage
        self.readingMode = readingMode
        self.sweetness = sweetness
        self.tartness = tartness
        self.bitterness = bitterness
        self.observation = observation
        self.careNote = careNote
        self.lastGeneratedCue = lastGeneratedCue
        self.lastGeneratedReason = lastGeneratedReason
    }

    var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
}

enum FlavorSceneSaveError: LocalizedError, Equatable {
    case emptyTitle
    case simulatedFailure
    case storageFailure(String)

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Name this Flavor Scene before saving."
        case .simulatedFailure:
            return "Couldn’t save this Flavor Scene. Try again."
        case .storageFailure(let message):
            return "Couldn’t save this Flavor Scene: \(message)"
        }
    }
}

enum AppRoute: Hashable {
    case studio(FlavorSceneDraft)
    case detail(UUID)
    case paywall
    case privacy
}

extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
