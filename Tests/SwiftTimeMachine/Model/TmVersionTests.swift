//
// Created by Brian Henry on 3/2/23.
//
@testable import SwiftTimeMachine

import Foundation
import XCTest

final class VersionTests: XCTestCase {

    func testParseString() throws {

        let filename = "version1"

        let bundle = Bundle.module

        guard let path = bundle.path(forResource: filename, ofType: "txt"),
              let content = try? String(contentsOfFile: path) else {
            continueAfterFailure = false
            XCTFail("File error: \(filename)")
            return
        }

        guard let sut = TmVersion(message: content) else {
            XCTFail("Failed to parse string")
            return
        }

        var dateComponents = DateComponents()
        dateComponents.day = 6
        dateComponents.month = 3
        dateComponents.year = 2023
        let expectedDate = Calendar.current.date(from: dateComponents) ?? Date()

        XCTAssertEqual( "4.0.0", sut.version )
        XCTAssertEqual( expectedDate, sut.buildDate )
        XCTAssertEqual( "tmutil version 4.0.0 (built Mar 6 2023)", sut.description )
    }

    func testParseStringWithTrailingLine() throws {

        let filename = "version2"

        let bundle = Bundle.module

        guard let path = bundle.path(forResource: filename, ofType: "txt"),
              let content = try? String(contentsOfFile: path) else {
            continueAfterFailure = false
            XCTFail("File error: \(filename)")
            return
        }

        guard let sut = TmVersion(message: content) else {
            XCTFail("Failed to parse string")
            return
        }

        var dateComponents = DateComponents()
        dateComponents.day = 6
        dateComponents.month = 3
        dateComponents.year = 2023
        let expectedDate = Calendar.current.date(from: dateComponents) ?? Date()

        XCTAssertEqual( "4.0.0", sut.version )
        XCTAssertEqual( expectedDate, sut.buildDate )
        XCTAssertEqual( "tmutil version 4.0.0 (built Mar 6 2023)", sut.description )
    }
}