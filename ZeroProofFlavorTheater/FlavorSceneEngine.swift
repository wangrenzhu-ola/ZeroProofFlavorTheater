import Foundation

struct FlavorSceneEngine {
    static func evaluate(_ draft: FlavorSceneDraft, previous: FlavorSceneRecord?) -> (cue: FlavorCue, reason: String, flavorHex: String, comparison: String) {
        guard draft.readingMode == .tested else {
            return (.watch, "No tasting pass was logged today, so keep the flavor scene visible and retaste before serving.", "D9911A", comparisonCopy(newCue: .watch, previous: previous))
        }
        if draft.availableIngredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.proportionCard.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.sweetness >= 8 || draft.tartness <= 1 || draft.bitterness >= 8 || draft.observation == .needsBite {
            return (.intervene, "One flavor balance, ingredient list, or proportion card needs a safer remix before serving.", "D9534F", comparisonCopy(newCue: .intervene, previous: previous))
        }
        if draft.sweetness >= 7 || draft.observation == .tooSweet || draft.observation == .flatFinish || draft.observation == .garnishMissing {
            return (.watch, "The drink is usable, but this note deserves a small adjustment before the next guest pour.", "D9911A", comparisonCopy(newCue: .watch, previous: previous))
        }
        return (.stable, "Flavor notes and guest reaction line up with a balanced zero-proof moment.", "2FA872", comparisonCopy(newCue: .stable, previous: previous))
    }

    static func comparisonCopy(newCue: FlavorCue, previous: FlavorSceneRecord?) -> String {
        guard let previous else { return "First saved Flavor Scene — the next one will compare cue changes here." }
        if previous.cue == newCue { return "Still \(newCue.rawValue): newest cue matches \(previous.title)." }
        return "Changed from \(previous.cue.rawValue) to \(newCue.rawValue) since \(previous.title)."
    }

    static func aiFallbackNote(for draft: FlavorSceneDraft) -> String {
        "Manual cue: \(draft.occasion) uses \(draft.availableIngredients) in a \(draft.glassware.rawValue.lowercased()) with \(draft.garnish.rawValue.lowercased()). Keep proportions editable; no AI route or save happens without your confirmation."
    }
}
