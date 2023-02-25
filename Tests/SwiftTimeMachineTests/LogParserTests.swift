//
// Created by Brian Henry on 2/24/23.
//

@testable import SwiftTimeMachine

import XCTest

final class LogParserTests: XCTestCase {

    func testAll() {
        for n in 1..<52 {
            try! message(number: n)
        }
    }

    func message(number: Int) throws {

        let bundle = Bundle.module

        let str = String(number)
        let paddingZero = String(repeating: "0", count: 3 - str.count)

        guard let path = bundle.path(forResource: "message\(paddingZero)\(number)", ofType: "txt"),
              let content = try? String(contentsOfFile: path) else {
            continueAfterFailure = false
            XCTFail("File error")
            return
        }

        let sut = LogParser()

        let parsed = sut.parse(logLine: content)

        var expected: LogEntry.LogType = .Info

        let errors = [16, 18, 21, 22, 23, 24, 38, 40, 46]
        if errors.contains(number) {
            expected = .Error
        }

        XCTAssertEqual(expected, parsed?.logType)
    }

}
