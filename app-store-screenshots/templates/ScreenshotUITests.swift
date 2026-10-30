import XCTest

/// Raw screens for the App Store visuals, not a test of behaviour: each step attaches a screenshot, which
/// `Scripts/screenshots.sh` exports from the `.xcresult` as PNGs.
///
/// The language and locale come from the runner's environment (`TEST_RUNNER_SCREENSHOT_LANGUAGE`, …), so one
/// test covers every localisation. Appearance and status bar are set on the simulator by the script: a UI
/// test can change neither.
///
/// Template: one test per launch state, screenshots named `NN-name` (two digits, a dash, no underscore).
/// The launch flags below are examples: the app reads them from `UserDefaults`, in DEBUG only.
final class ScreenshotUITests: XCTestCase {
    /// Mirrors the app's accessibility identifiers, which a UI test cannot import.
    private enum Identifiers {
        static let onboardingContinue = "onboarding.continue"
        static let listItem = "list.item"
        static let detailBack = "detail.back"
    }

    /// Marketing content, not test data: change it with the app's DEBUG seed.
    private enum Content {
        /// The item whose detail is captured, by position: cells share one identifier.
        static let featuredIndex = 3
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testOnboarding() {
        let app = launchApp(hasCompletedOnboarding: false, seeded: false)

        waitUntil("isHittable == true", on: app.buttons[Identifiers.onboardingContinue])
        snapshot("01-onboarding")
    }

    func testMain() {
        let app = launchApp(hasCompletedOnboarding: true, seeded: true)

        let featured = app.buttons.matching(identifier: Identifiers.listItem).element(boundBy: Content.featuredIndex)
        waitUntil("isHittable == true", on: featured)
        snapshot("10-list")

        featured.tap()
        waitUntil("isHittable == true", on: app.buttons[Identifiers.detailBack])
        snapshot("12-detail")
    }
}

// MARK: - Steps

extension ScreenshotUITests {
    /// The flags are the app's DEBUG launch arguments: demo data in memory, permissions stated up front so no
    /// system alert stalls the run, and any timer that would close a screen before its capture held open.
    private func launchApp(hasCompletedOnboarding: Bool, seeded: Bool) -> XCUIApplication {
        let environment = ProcessInfo.processInfo.environment
        let language = environment["SCREENSHOT_LANGUAGE"] ?? "en"
        let locale = environment["SCREENSHOT_LOCALE"] ?? "en_US"

        let app = XCUIApplication()
        app.launchArguments = [
            // The argument domain outranks what the app writes: this one cannot be finished in the same launch.
            "-hasCompletedOnboarding", hasCompletedOnboarding ? "YES" : "NO",
            seeded ? "-seedDemoData" : "-emptyStore", "YES",
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", locale
        ]
        app.launch()
        return app
    }

    /// A hittable element can still be mid-animation, and no element state says when the screen has settled —
    /// hence the fixed pause before the capture.
    private func snapshot(_ name: String, settle: TimeInterval = 1) {
        Thread.sleep(forTimeInterval: settle)
        let attachment = XCTAttachment(screenshot: litScreenshot())
        attachment.name = name
        // Otherwise Xcode drops the attachments of a passing test.
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// The iPhone Duo has two screens, and `XCUIScreen.main` is the outer one, black while unfolded: keep the
    /// one the app's window fits, else the largest.
    private func litScreenshot() -> XCUIScreenshot {
        let screens = XCUIScreen.screens
        guard screens.count > 1 else { return XCUIScreen.main.screenshot() }

        let window = XCUIApplication().windows.firstMatch.frame.size
        let shots = screens.map { $0.screenshot() }
        if let match = shots.first(where: { $0.image.size == window }) {
            return match
        }
        let area = { (shot: XCUIScreenshot) in shot.image.size.width * shot.image.size.height }
        return shots.max { area($0) < area($1) } ?? shots[0]
    }
}

// MARK: - Waiting

extension ScreenshotUITests {
    private func waitUntil(
        _ predicate: String,
        on element: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: predicate), object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: 10)
        XCTAssertEqual(result, .completed, "Never satisfied: \(predicate)", file: file, line: line)
    }
}
