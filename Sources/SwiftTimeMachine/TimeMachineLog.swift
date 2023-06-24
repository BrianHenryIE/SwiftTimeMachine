//
//  TimeMachineLogMonitor.swift
//
//  Created by Brian Henry on 5/21/22.
//
// `/usr/bin/log stream --predicate 'subsystem == "com.apple.TimeMachine"' --info`
//

import Foundation
import DequeModule
import BHSwiftOSLogStream
import OSLog

public extension Notification.Name {

    static let TimeMachineLogAll = NSNotification.Name("ie.brianhenryie.timemachinelog.all")
    static let TimeMachineLogAfterCompletedBackup = NSNotification.Name("ie.brianhenryie.timemachinelog.aftercompletedbackup")
    static let TimeMachineLogAfterThinning = NSNotification.Name("ie.brianhenryie.timemachinelog.afterthinning")
    static let TimeMachineLogAfterCompletedBackupNoThinning = NSNotification.Name("ie.brianhenryie.timemachinelog.aftercompletedbackupnothinning")

}

@available(macOS 10.13, *)
open class TimeMachineLog: NotificationCenter, LogStreamDelegateProtocol {

    // "static properties are executed lazily by default".
    // i.e. reading of the log file will not begin unless a notification is subscribed to.
    public static let shared = TimeMachineLog()

    public private(set) var previousInfoLogs = History<LogEntry>(maxSize: 3)

    override init() {
        super.init()

        let stream = LogStream(subsystem: "com.apple.TimeMachine", delegate: self)
    }

    public func newLogEntry(entry logEntry: LogEntry, history: History<LogEntry>) {

        let logMessage = logEntry.message

        if let captureRange = logMessage.range(of: #"Mountpoint '(/Volumes/.*?)' is still valid"#,
                options: .regularExpression),
            let previousLogMessage = previousInfoLogs.get() {

            let volume = logMessage[captureRange]

            switch previousLogMessage {
            case _ where previousInfoLogs.get()?.message.contains("Completed backup") ?? false:

                os_log( "Backup to %public%@ complete.", volume )

                self.post(name: .TimeMachineLogAfterCompletedBackup, object: self)
            case _ where previousInfoLogs.get()?.message.starts(with: "Thinning") ?? false:

                os_log( "Backup to %public%@ and cleanup complete.", volume )

                self.post(name: .TimeMachineLogAfterThinning, object: self)
            case _ where previousInfoLogs.get()?.message.starts(with: "Mountpoint") ?? false
                && previousInfoLogs.get()?.message.starts(with: "Thinning") ?? false:

                os_log( "Backup to %public%@ complete without cleanup.", volume )

                self.post(name: .TimeMachineLogAfterCompletedBackupNoThinning, object: self)
            default:
// TODO: Getting a lot of empty logMessage here
                os_log( "%public%@ message followed: %public%@", logMessage, previousInfoLogs.get()?.message ?? "nothing")
                break
            }

        }

        self.post(name: .TimeMachineLogAll, object: self)

        if  logEntry.logType == .Info {
            previousInfoLogs.append(item: logEntry)
        }
    }
}
