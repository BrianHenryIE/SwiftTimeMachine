//
// Created by Brian Henry on 6/10/23.
//

import Foundation

@testable import SwiftTimeMachine

import Foundation
import XCTest

final class TmStatusTests: XCTestCase {

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

}