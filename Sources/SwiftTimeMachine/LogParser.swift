//
// Created by Brian Henry on 2/24/23.
//

import Foundation

class LogParser {

    private let logParserPattern = #"""
                               (?<timestamp>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\.\d{6}-\d{4})
                               \s+
                               (?<thread>0x\w+)
                               \s+
                               (?<type>\w+)
                               \s+
                               (?<activity>0x\w+)
                               \s+
                               (?<pid>\d+)
                               \s+
                               (?<ttl>\d+)
                               \s+
                               (?<context>.*?)
                               \s
                               \[(?<namespace>.*?):(?<namespacecontext>.*?)\]
                               \s+
                               (?<message>.*)
                           """#

    private let logParserRegex: NSRegularExpression

    private let dateFormatter: DateFormatter

    init() {
        logParserRegex = try! NSRegularExpression(pattern: logParserPattern, options: [NSRegularExpression.Options.allowCommentsAndWhitespace,NSRegularExpression.Options.dotMatchesLineSeparators])
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSSZ"
    }

    func parse(logLine: String) -> LogEntry? {

        let logLineRange = NSRange(logLine.startIndex..<logLine.endIndex, in: logLine)

        let matches = logParserRegex.matches(in: logLine, options: [], range: logLineRange)

        guard let match = matches.first else {
            return nil
        }

        var captures: [String: String] = [:]

        for name in ["timestamp", "thread", "type", "activity", "pid", "ttl","context","namespace","namespaceContext","message"] {
            let matchRange = match.range(withName: name)

            // Extract the substring matching the named capture group
            if let substringRange = Range(matchRange, in: logLine) {
                let capture = String(logLine[substringRange])
                captures[name] = capture
            }
        }

        let timestampString = captures["timestamp"]!
        let threadString = captures["thread"]!
        let typeString = captures["type"]!
        let activityString = captures["activity"]!
        let pidString = captures["pid"]!
        let ttlString = captures["ttl"]!
        let contextString = captures["context"]!
        let namespaceString = captures["namespace"]!
        let namespaceContextString = captures["namespaceContext"]
        let messageString = captures["message"]!

        // 2023-02-17 19:12:13.456317-0800
        guard let timestampDate = dateFormatter.date(from: timestampString) else {
            return nil
        }

        guard let logType = LogEntry.LogType(rawValue: typeString) else {
            return nil
        }

        guard let pidInt = Int(pidString) else {
            return nil
        }

        guard let ttlInt = Int(ttlString) else {
            return nil
        }

        let namespace = LogEntry.NameSpace(namespace: namespaceString, namespaceContext: namespaceContextString)

        return LogEntry(
                timestamp: timestampDate,
                thread: threadString,
                logType: logType,
                activity: activityString,
                pid: pidInt,
                context: contextString,
                ttl: ttlInt,
                namespace: namespace,
                message: messageString
        )

    }

}
