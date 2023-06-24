//
// Created by Brian Henry on 6/10/23.
//

import Foundation

@testable import SwiftTimeMachine

import Foundation
import XCTest

final class TmStatusTests: XCTestCase {

    // Let's check does everything even parse before checking values
    func testCanParseAll() throws {
        for number in 1..<5 {

            let str = String(number)
            let paddingZero = String(repeating: "0", count: 2 - str.count)
            let filename = "status\(paddingZero)\(number)"

            guard let content = getFileContents(filename: filename) else {
                XCTFail("Failed to read \(filename).txt")
                return
            }

            let tmStatusDecoder = TmStatusDecoder()

            try tmStatusDecoder.decode(TmStatus.self, from: Data(content.utf8))

            XCTAssertTrue(true)
        }
    }

    func testParseStatus01() throws {

        let filename = "status01"

        guard let content = getFileContents(filename: filename) else {
            XCTFail("Failed to read \(filename).txt")
            return
        }

        let tmStatusDecoder = TmStatusDecoder()

        guard let tmStatus =  try? tmStatusDecoder.decode(TmStatus.self, from: Data(content.utf8)) else {
            XCTFail("Failed to parse \(filename).txt")
            return
        }

        // ClientID = "com.apple.backupd";
        XCTAssertEqual( "com.apple.backupd", tmStatus.clientID )

        // Percent = "-1";
        XCTAssertEqual( -1, tmStatus.percent! )

        // Running = 0;
        XCTAssertEqual( false, tmStatus.running )
    }

    func testParseStatus02() throws {

        let filename = "status02"

        guard let content = getFileContents(filename: filename) else {
            XCTFail("Failed to read \(filename).txt")
            return
        }

        let tmStatusDecoder = TmStatusDecoder()

        try tmStatusDecoder.decode(TmStatus.self, from: Data(content.utf8))

        guard let tmStatus =  try? tmStatusDecoder.decode(TmStatus.self, from: Data(content.utf8)) else {
            XCTFail("Failed to parse \(filename).txt")
            return
        }

        // BackupPhase = PreparingSourceVolumes;
        XCTAssertEqual( TmCurrentPhase.PreparingSourceVolumes, tmStatus.backupPhase! )

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
        XCTAssertEqual( "8818CBEE-8A5D-4859-A4A7-4B3B7885CFEB", tmStatus.destinationID! )

        // DestinationMountPoint = "/Volumes/8tb";
        XCTAssertEqual( "/Volumes/8tb", tmStatus.destinationMountPoint! )

        // Stopping = 0;
        XCTAssertEqual( false, tmStatus.stopping! )
    }

    func testParseStatus03() throws {

        let filename = "status03"

        guard let content = getFileContents(filename: filename) else {
            XCTFail("Failed to read \(filename).txt")
            return
        }

        let tmStatusDecoder = TmStatusDecoder()

        try tmStatusDecoder.decode(TmStatus.self, from: Data(content.utf8))

        guard let tmStatus =  try? tmStatusDecoder.decode(TmStatus.self, from: Data(content.utf8)) else {
            XCTFail("Failed to parse \(filename).txt")
            return
        }

        // FractionDone = 1;
        XCTAssertEqual( 1, tmStatus.fractionDone! )

        // FractionOfProgressBar = "0.1";
        XCTAssertEqual( 0.1, tmStatus.fractionOfProgressBar! )
    }

    func testParseStatus04() throws {

        let filename = "status04"

        guard let content = getFileContents(filename: filename) else {
            XCTFail("Failed to read \(filename).txt")
            return
        }

        let tmStatusDecoder = TmStatusDecoder()

        let tmStatus = try tmStatusDecoder.decode(TmStatus.self, from: Data(content.utf8))

        // Percent = "0.005664367164145429";
        XCTAssertEqual( 0.005664367164145429, tmStatus.progress!.percent )
        // "_raw_Percent" = "0.005664367164145429";
        XCTAssertEqual( 0.005664367164145429, tmStatus.progress!.rawPercent )
        // "_raw_totalBytes" = 1805307203584;
        XCTAssertEqual( 1805307203584, tmStatus.progress!.rawTotalBytes)
        // bytes = 0;
        XCTAssertEqual( 0, tmStatus.progress!.bytes )
        // files = 0;
        XCTAssertEqual( 0, tmStatus.progress!.files )
        // sizingFreePreflight = 1;
        XCTAssertEqual( true, tmStatus.progress!.sizingFreePreflight )
        // totalBytes = 1805307203584;
        XCTAssertEqual( 1805307203584, tmStatus.progress!.totalBytes )
        // totalFiles = 10159895;
        XCTAssertEqual( 10159895, tmStatus.progress!.totalFiles )
    }

    func testParseStatus05() throws {

        let filename = "status05"

        guard let content = getFileContents(filename: filename) else {
            XCTFail("Failed to read \(filename).txt")
            return
        }

        let tmStatusDecoder = TmStatusDecoder()

        let tmStatus = try tmStatusDecoder.decode(TmStatus.self, from: Data(content.utf8))

        XCTAssertEqual( "8818CBEE-8A5D-4859-A4A7-4B3B7885CFEB", tmStatus.destinationID! )
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