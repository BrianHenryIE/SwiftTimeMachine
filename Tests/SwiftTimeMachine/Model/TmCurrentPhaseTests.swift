//
// Created by Brian Henry on 6/13/23.
//

import Foundation

@testable import SwiftTimeMachine

import Foundation
import XCTest

final class TmCurrentPhaseTests: XCTestCase {

    // Let's check does everything even parse before checking values
    func testCanParseAll() throws {
        for number in 1...1 {

            let str = String(number)
            let filename = "currentphase\(number)"

            guard let content = getFileContents(filename: filename) else {
                XCTFail("Failed to read \(filename).txt")
                return
            }

            let tmStatusDecoder = TmStatusDecoder()

            let currentPhase = TmCurrentPhase(rawValue: content)

            XCTAssertNotNil(currentPhase)
        }
    }


    func testParse1() throws {

        let filename = "currentphase1"

        guard let content = getFileContents(filename: filename) else {
            XCTFail("Failed to read \(filename).txt")
            return
        }

        guard let tmCurrentPhase = TmCurrentPhase(rawValue: content) else {
            XCTFail("Failed to parse \(filename).txt")
            return
        }

        // BackupNotRunning
        XCTAssertEqual( TmCurrentPhase.BackupNotRunning, tmCurrentPhase )
    }
}