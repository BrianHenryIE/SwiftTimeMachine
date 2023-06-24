//
// Created by Brian Henry on 6/13/23.
//

import Foundation
import XCTest

extension XCTestCase {

    func getFileContents( filename: String ) -> String? {

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