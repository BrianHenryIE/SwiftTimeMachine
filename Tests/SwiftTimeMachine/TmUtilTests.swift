//
// Created by Brian Henry on 6/11/23.
//
// Actually runs TmUtil...

import Foundation

@testable import SwiftTimeMachine

import Foundation
import XCTest

final class TmUtilTests: XCTestCase {

    func testVersion() throws {

        let tmUtil = TmUtil()

        let version = tmUtil.version()

        XCTAssertEqual( "4.0.0", version!.version )
    }

    func testDestination() throws {

        let tmUtil = TmUtil()

        let destination = tmUtil.destinationInfo()?.destinations.first!

        XCTAssertEqual( .local, destination!.kind )
    }

}