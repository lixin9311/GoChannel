import XCTest
@testable import GoChannel

final class GoChannelTests: XCTestCase {
    func testUnbuffered() async throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        var c = Chan<String>()
        Task.init { [c] in
            print("sending...")
            try await c <- "Hello, World!"
            print("sent")
        }
        print("recving...")
        if let str : String = try await <-c {
            XCTAssertEqual(str, "Hello, World!")
            print("received")
        } else {
            XCTFail("unexpected")
        }
    }
}
