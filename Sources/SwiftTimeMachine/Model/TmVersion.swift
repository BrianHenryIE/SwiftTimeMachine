//
// Created by Brian Henry on 6/9/23.
//
// https://swiftregex.com/

import Foundation
import RegexBuilder

public struct TmVersion: TmResult, CustomStringConvertible {

    let version: String
    let buildDate: Date

    // tmutil version 4.0.0 (built Mar  6 2023)
    init?(message: String) {

        let capturedVersion = Reference(Substring.self)
        let capturedBuildDate = Reference(Date?.self)

        let regex = Regex {
            "tmutil version "
            Capture(as: capturedVersion) {
                Regex {
                    OneOrMore(.digit)
                    "."
                    OneOrMore(.digit)
                    "."
                    OneOrMore(.digit)
                }
            }
            " (built "
            TryCapture(as: capturedBuildDate) {
                Regex {
                    OneOrMore(.word)
                    OneOrMore(.whitespace)
                    OneOrMore(.digit)
                    " "
                    Repeat(count: 4) {
                        One(.digit)
                    }
                }
            } transform: {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d yyyy"
                return dateFormatter.date(from: String($0))
            }
            ")"
            ZeroOrMore {
                .any
            }
        }
                .anchorsMatchLineEndings()

        guard let matches = try? regex.wholeMatch(in: message),
              let buildDate = matches[capturedBuildDate]
            else {
            return nil
        }

        version = String(matches[capturedVersion])
        self.buildDate = buildDate
    }

    // Actual input is: "tmutil version 4.0.0 (built Mar  6 2023)".
    // Output is:       "tmutil version 4.0.0 (built Mar 6 2023)"
    public var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d yyyy"
        let buildDateString = dateFormatter.string(from: buildDate)

        return "tmutil version \(version) (built \(buildDateString))"
    }
}
