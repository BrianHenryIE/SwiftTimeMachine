//
// Created by Brian Henry on 6/10/23.
//
//
// After writing this I learned that adding `-X` to `tmutil status` will return XML/plist.

import Foundation
import OSLog

public typealias StringEncodedBool = Bool
public typealias IntEncodedBool = Bool
public typealias StringEncodedDouble = Double

extension TmStatusKey {
    static var decodingStrategy: ([CodingKey]) -> CodingKey {
        {
            TmStatusKey(stringValue: $0.last!.stringValue)!
        }
    }
}

// https://developer.apple.com/documentation/foundation/jsondecoder/keydecodingstrategy/custom
struct TmStatusKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue originalKey: String) {

        // Is there any way to use the actual `.convertFromSnakeCase` here?
        // Split the string by `_`, uppercase the first of each part, then join them.
        let components = originalKey.components(separatedBy: "_")
        var modifiedKey = components.map {
                    $0.prefix(1).uppercased() + $0.dropFirst()
                }.joined()
        // Lowercase the very first letter.
        modifiedKey = modifiedKey.prefix(1).lowercased() + modifiedKey.dropFirst()

        self.stringValue = modifiedKey
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {

    // Parse Strings to Doubles
    public func decode(_ type: StringEncodedDouble.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Double {
        if let stringValue = try? decodeIfPresent(String.self, forKey: key),
           let doubleValue = Double(stringValue) {
            return doubleValue
        }
        return try superDecoder(forKey: key).singleValueContainer().decode(Double.self)
    }

    // Parse optional Strings to Doubles
    func decodeIfPresent(_ type: StringEncodedDouble.Type, forKey key: K) throws -> Double? {
        if let stringValue = try? decodeIfPresent(String.self, forKey: key),
                let doubleValue = Double(stringValue) {
            return doubleValue
        }
        return try? self.decode(type, forKey: key)
    }

    // Parse Bools encoded as Ints.
    public func decode(_ type: IntEncodedBool.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Bool {

        if let stringValue = try? decode(String.self, forKey: key) {
            return stringValue == "1"
        }

        if let intValue = try? decode(Int.self, forKey: key) {
            return intValue == 1
        }

        return try superDecoder(forKey: key).singleValueContainer().decode(Bool.self)
    }

    // Parse optional Bools from Int
    func decodeIfPresent(_ type: IntEncodedBool.Type, forKey key: K) throws -> IntEncodedBool? {

        if let stringValue = try? decode(String.self, forKey: key) {
            return stringValue == "1"
        }

        if let intValue = try? decode(Int.self, forKey: key) {
            return intValue == 1
        }

        return try? self.decode(type, forKey: key)
    }

    // Parse the ISO8601 date which is used.
    func decodeIfPresent(_ type: Date.Type, forKey key: K) throws -> Date? {
        guard let stringValue = try? decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withDay,
            .withMonth,
            .withYear,
            .withTime,
            .withTimeZone,
            .withColonSeparatorInTime,
            .withDashSeparatorInDate,
            .withSpaceBetweenDateAndTime
        ]
        return dateFormatter.date(from: stringValue)
    }
}

class TmStatusDecoder: JSONDecoder {

    func decode(from data: Input) -> TmStatus? {
        if let decoded = try? decode(TmStatus.self, from: data) {
            return decoded
        } else {
            os_log(
                    "%{public}@",
                    log: .default,
                    type: .error,
                    String(data: data, encoding: String.Encoding.utf8) ?? "failed to show TmStatus parse failure message"
            )
            return nil
        }
    }

    override func decode<T>(_ type: T.Type, from: Input) throws -> T where T: Decodable {

        keyDecodingStrategy = .custom(TmStatusKey.decodingStrategy)

        let tmStatusInputString = String(decoding: from, as: UTF8.self)
        var lines = tmStatusInputString.split(whereSeparator: \.isNewline).dropFirst().joined(separator: "\n")
        let json = convertToJson(from: lines)
        let updatedData: Input  = Data(json.utf8)

        return try super.decode(type, from: updatedData)
    }

    public func convertToJson(from: String) -> String {

        // change the `=` separator to `:`
        let equalsRegex = "(\\s=\\s)"
        let colonReplacement = ":"
        var json = from.replacingOccurrences(of: equalsRegex, with: colonReplacement, options: [.regularExpression])

        // Add `"` around the key,
        let regex = "\n(\\s+\"?)([^\\s]*?)\"?\\s*:"
        let repl = "\n\"$2\":"
        json = json.replacingOccurrences(of: regex, with: repl, options: [.regularExpression])

        // Change the trailing `;` to `,` after numbers.
        let semiColonToCommaAfterNumericRegex = ":\\s*(\\d+)\\s*;\\n"
        let commaReplacementAfterNumericRegex = ": $1,\n"
        json = json.replacingOccurrences(of: semiColonToCommaAfterNumericRegex, with: commaReplacementAfterNumericRegex, options: [.regularExpression])

        // Change the trailing `;` to `",` after unquoted alphanumeric.
        let semiColonToCommaAfterUnquotedAlphanumericRegex = ":\\s*(\\w*)\\s*;\\n"
        let commaReplacementAfterUnquotedAlphanumericRegex = ": \"$1\",\n"
        json = json.replacingOccurrences(of: semiColonToCommaAfterUnquotedAlphanumericRegex, with: commaReplacementAfterUnquotedAlphanumericRegex, options: [.regularExpression])

        // Change the trailing `;` to `",` after quoted values.
        let semiColonToCommaAfterQuotedValueRegex = ":(.*?);\\n"
        let commaReplacementAfterQuotedValueRegex = ": $1,\n"
        json = json.replacingOccurrences(of: semiColonToCommaAfterQuotedValueRegex, with: commaReplacementAfterQuotedValueRegex, options: [.regularExpression])

        // Remove the remaining `;` before the closing `}`
        let endofObjectSemiColonRegex = "\\s*\\n\\s*\\}\\s*;\\s*\\n"
        let endofObjectCommaReplacement = "\n},\n"
        json = json.replacingOccurrences(of: endofObjectSemiColonRegex, with: endofObjectCommaReplacement, options: [.regularExpression])

        // Remove the remaining `;` before the closing `}`
        let lastCommaInClassRegex = ",\\s*\\n*\\s*\\}"
        let noCommaReplacement = "\n}"
        json = json.replacingOccurrences(of: lastCommaInClassRegex, with: noCommaReplacement, options: [.regularExpression])

        return json
    }

}
