//
// Created by Brian Henry on 6/9/23.
//
// tmutil destinationinfo -X

@testable import SwiftTimeMachine

import Foundation
import XCTest

final class TmDestinationInfoTests: XCTestCase {

    // Let's check does everything even parse before checking values
    func testCanParseAtAll() throws {

        for number in 1..<2 {

            let str = String(number)
            let filename = "destinationinfo-xml\(number)"

            guard let content = getFileContents(filename: filename) else {
                XCTFail("Failed to read \(filename).txt")
                return
            }

            let decoder = TmDestinationInfoDecoder()

            let result = decoder.decode(from: Data(content.utf8))

            XCTAssertTrue(true)
        }

    }

    func test01() throws {
        let filename = "destinationinfo-xml1"

        guard let content = getFileContents(filename: filename) else {
            XCTFail("Failed to read \(filename).txt")
            return
        }


        let decoder = PropertyListDecoder()

        let destinationinfo = try decoder.decode(TmDestinationInfo.self, from: Data(content.utf8))

        let destination = destinationinfo.destinations.first!

        // Name          : 9168227426-F4
        XCTAssertEqual("9168227426-F4", destination.name)
        // Kind          : Local
        XCTAssertEqual( .local, destination.kind)
        // ID            : 511D3A0B-8810-4704-B45B-E2A2FFC26DAE
        XCTAssertEqual("511D3A0B-8810-4704-B45B-E2A2FFC26DAE", destination.id)

        XCTAssertTrue( destination.lastDestination! )
    }


    func test02() throws {
        let filename = "destinationinfo-xml2"

        guard let content = getFileContents(filename: filename) else {
            XCTFail("Failed to read \(filename).txt")
            return
        }

        let decoder = PropertyListDecoder()

        let destinationinfo = try decoder.decode(TmDestinationInfo.self, from: Data(content.utf8))

        let destination = destinationinfo.destinations.first!

        XCTAssertEqual( "/Volumes/9168227426-F4", destination.mountPoint! )
    }


    private func getFileContents( filename: String ) -> String? {

        let bundle = Bundle.module

        guard let path = bundle.path(forResource: filename, ofType: "txt"),
              let content = try? String(contentsOfFile: path)
        else {
            continueAfterFailure = false
            XCTFail("File error: \(filename).txt")
            return nil
        }

        return content
    }
}