import XCTest
@testable import ZeroProofFlavorTheater

final class FlavorSceneEngineTests: XCTestCase {
    func testInterveneCueForUnbalancedFlavor() {
        var draft = FlavorSceneDraft.blank
        draft.title = "Cloudy bowl"
        draft.bitterness = 9
        let result = FlavorSceneEngine.evaluate(draft, previous: nil)
        XCTAssertEqual(result.cue, .intervene)
        XCTAssertTrue(result.reason.contains("outside"))
    }

    func testNotTastedStaysWatchAndManual() {
        var draft = FlavorSceneDraft.blank
        draft.readingMode = .notTested
        let result = FlavorSceneEngine.evaluate(draft, previous: nil)
        XCTAssertEqual(result.cue, .watch)
        XCTAssertTrue(result.reason.contains("No tasting pass"))
    }
}
