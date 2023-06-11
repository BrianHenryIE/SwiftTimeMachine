//
// Created by Brian Henry on 6/10/23.
//

import Foundation

import Foundation

@testable import SwiftTimeMachine

import Foundation
import XCTest

final class TmStatusDecoderTests: XCTestCase {

    func testConvertFromJsonNoChanges() throws {

        let sut = TmStatusDecoder()

        let jsonString = """
                         Whatever
                         [0, 1, 2]
                         """
        let jsonData = jsonString.data(using: .utf8)!
        let dRes = try! sut.decode([Int].self, from: jsonData)

        XCTAssertEqual(1, dRes[1])
    }

    func testConvert() throws {
        let sut = TmStatusDecoder()

        let input = """
                    Backup session status:
                    {
                        ClientID = "com.apple.backupd";
                        Percent = "-1";
                        Running = 0;
                    }
                    """

        let result: TmStatus = try! sut.decode(TmStatus.self, from: Data(input.utf8))

        XCTAssertEqual( "com.apple.backupd", result.clientID )
        XCTAssertEqual( -1, result.percent! )
        XCTAssertFalse( result.running )
    }

}