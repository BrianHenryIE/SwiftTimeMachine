//
// Created by Brian Henry on 6/10/23.
//

import Foundation

@testable import SwiftTimeMachine

import Foundation
import XCTest

final class TmStatusTests: XCTestCase {

    // Let's check does everything even parse before checking values
    func testCanParseAll() {
        for number in 1..<5 {

            let str = String(number)
            let paddingZero = String(repeating: "0", count: 2 - str.count)
            let filename = "status\(paddingZero)\(number)"

            guard let content = getFileContents(filename: filename),
                  let parsed = TmStatus(message: content) else {
                XCTFail("Failed to parse: status\(paddingZero)\(number).txt")
                return
            }

            XCTAssertTrue(true)
        }
    }

    func testParseStatus01() throws {

        let filename = "status01"

        guard let content = getFileContents(filename: filename),
              let tmStatus = TmStatus(message: content) else {
            XCTFail("Failed to parse \(filename).txt")
            return
        }

        // ClientID = "com.apple.backupd";
        XCTAssertEqual( "com.apple.backupd", tmStatus.clientId )

        // Percent = "-1";
        XCTAssertEqual( -1, tmStatus.percent! )

        // Running = 0;
        XCTAssertEqual( false, tmStatus.running )
    }

    func testParseStatus02() throws {

        let filename = "status02"

        guard let content = getFileContents(filename: filename),
              let tmStatus = TmStatus(message: content) else {
            XCTFail("Failed to parse \(filename).txt")
            return
        }

        // BackupPhase = PreparingSourceVolumes;
        XCTAssertEqual( TmStatus.BackUpPhase.PreparingSourceVolumes, tmStatus.backupPhase! )

        // DateOfStateChange = "2023-02-27 01:08:48 +0000";
        var dateComponents = DateComponents()
        dateComponents.day = 27
        dateComponents.month = 2
        dateComponents.year = 2023
        dateComponents.hour = 1
        dateComponents.minute = 8
        dateComponents.second = 48
        dateComponents.timeZone = TimeZone.gmt
        let expectedDate = Calendar.current.date(from: dateComponents) ?? Date()
        XCTAssertEqual( expectedDate, tmStatus.dateOfStateChange! )

        // DestinationID = "8818CBEE-8A5D-4859-A4A7-4B3B7885CFEB";
//        XCTAssertEqual( "8818CBEE-8A5D-4859-A4A7-4B3B7885CFEB", tmStatus.destinationId! )

        // DestinationMountPoint = "/Volumes/8tb";
        XCTAssertEqual( "/Volumes/8tb", tmStatus.destinationMountPoint! )

        // Stopping = 0;
//        XCTAssertEqual( false, tmStatus.stopping! )

    }

    func testParseStatus05() throws {

        let filename = "status05"

        guard let content = getFileContents(filename: filename),
              let tmStatus = TmStatus(message: content) else {
            XCTFail("Failed to parse \(filename).txt")
            return
        }

//        XCTAssertEqual( "8818CBEE-8A5D-4859-A4A7-4B3B7885CFEB", tmStatus.destinationId! )
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