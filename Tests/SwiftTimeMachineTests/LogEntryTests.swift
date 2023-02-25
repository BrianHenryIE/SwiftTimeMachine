//
// Created by Brian Henry on 2/24/23.
//

@testable import SwiftTimeMachine

import XCTest


final class LogEntryTests: XCTestCase {

    func testEnum() throws {

        let result = LogEntry.LogType(rawValue:"info")

        XCTAssertEqual(LogEntry.LogType.Info, result)
    }

}
