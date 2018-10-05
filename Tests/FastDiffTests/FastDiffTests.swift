import XCTest
@testable import FastDiff

final class FastDiffTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FastDiff().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
