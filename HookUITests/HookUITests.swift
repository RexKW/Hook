import XCTest

final class HookUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMainScreenPopupsOpenAndClose() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.otherElements["topBar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["boatLevelText"].exists)
        XCTAssertTrue(app.staticTexts["playerProgressText"].exists)

        app.buttons["upgradeButton"].tap()
        XCTAssertTrue(app.otherElements["upgradePopup"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.otherElements["boatLevel1Row"].exists)

        app.buttons["upgradeCloseButton"].tap()
        XCTAssertFalse(app.otherElements["upgradePopup"].waitForExistence(timeout: 2))

        app.buttons["fishCollectionButton"].tap()
        XCTAssertTrue(app.otherElements["fishAlbumPopup"].waitForExistence(timeout: 2))

        app.buttons["fishAlbumCloseButton"].tap()
        XCTAssertFalse(app.otherElements["fishAlbumPopup"].waitForExistence(timeout: 2))
    }
}
