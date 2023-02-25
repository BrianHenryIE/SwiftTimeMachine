//
// Created by Brian Henry on 2/24/23.
//

import Foundation

struct LogEntry {

    enum LogType: String {
        case Info = "Info"
        case Error = "Error"
    }

    struct NameSpace {
        let namespace: String
        let namespaceContext: String?
    }

    let timestamp: Date

    let thread: String // Really a hex number 0x1234

    let logType: LogEntry.LogType

    let activity: String // Hex? 0x0

    let pid: Int

    let context: String

    let ttl: Int

    let namespace: LogEntry.NameSpace

    let message:String
}