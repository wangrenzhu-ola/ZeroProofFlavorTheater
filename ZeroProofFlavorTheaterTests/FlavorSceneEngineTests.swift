import XCTest
@testable import ZeroProofFlavorTheater

final class FlavorSceneEngineTests: XCTestCase {
    func testInterveneCueForUnbalancedFlavor() {
        var draft = FlavorSceneDraft.blank
        draft.title = "Cloudy bowl"
        draft.bitterness = 9
        let result = FlavorSceneEngine.evaluate(draft, previous: nil)
        XCTAssertEqual(result.cue, .intervene)
        XCTAssertTrue(result.reason.contains("remix"))
    }

    func testNotTastedStaysWatchAndManual() {
        var draft = FlavorSceneDraft.blank
        draft.readingMode = .notTested
        let result = FlavorSceneEngine.evaluate(draft, previous: nil)
        XCTAssertEqual(result.cue, .watch)
        XCTAssertTrue(result.reason.contains("No tasting pass"))
    }

    func testRequiresIngredientsAndProportionCard() {
        var draft = FlavorSceneDraft.blank
        draft.availableIngredients = ""
        let result = FlavorSceneEngine.evaluate(draft, previous: nil)
        XCTAssertEqual(result.cue, .intervene)
        XCTAssertTrue(result.reason.contains("ingredient"))
    }

    func testDraftCarriesPMFlavorSceneFields() throws {
        let draft = FlavorSceneDraft.blank
        XCTAssertTrue(draft.availableIngredients.contains("sparkling water"))
        XCTAssertTrue(draft.proportionCard.contains("oz"))
        XCTAssertFalse(draft.servingSteps.isEmpty)
        XCTAssertFalse(draft.guestReaction.isEmpty)
        _ = try JSONEncoder.flavorTheater.encode(draft)
    }

    func testStoreSavePersistsFlavorSceneFieldsInMemory() throws {
        let store = FlavorSceneStore()
        var draft = FlavorSceneDraft.blank
        draft.title = "Garden highball"
        draft.availableIngredients = "sparkling water, cucumber, lime, mint"
        draft.proportionCard = "4 oz sparkling water + 1 oz lime cordial"
        draft.guestReaction = "Guest asked for the garnish cue again."
        let saved = try store.save(draft)
        XCTAssertEqual(store.records.first?.id, saved.id)
        XCTAssertEqual(store.records.first?.availableIngredients, draft.availableIngredients)
        XCTAssertEqual(store.records.first?.proportionCard, draft.proportionCard)
        XCTAssertEqual(store.records.first?.guestReaction, draft.guestReaction)
    }
}
