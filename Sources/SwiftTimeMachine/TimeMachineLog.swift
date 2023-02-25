//
//  TimeMachineLogMonitor.swift
//
//  Created by Brian Henry on 5/21/22.
//
// `/usr/bin/log stream --predicate 'subsystem == "com.apple.TimeMachine"' --info`
//

import Foundation
import DequeModule

extension Notification.Name {

    struct TimeMachineLog {
        // Captials/no capitals convention?
        static let All = NSNotification.Name("ie.brianhenryie.timemachinelog.all")
        static let AfterCompletedBackup = NSNotification.Name("ie.brianhenryie.timemachinelog.aftercompletedbackup")
        static let AfterThinning = NSNotification.Name("ie.brianhenryie.timemachinelog.afterthinning")
        static let AfterCompletedBackupNoThinning = NSNotification.Name("ie.brianhenryie.timemachinelog.aftercompletedbackupnothinning")

    }

    // Captials/no capitals convention?
    static let TimeMachineLogAll = NSNotification.Name("ie.brianhenryie.timemachinelog.all")
    static let TimeMachineLogAfterCompletedBackup = NSNotification.Name("ie.brianhenryie.timemachinelog.aftercompletedbackup")
    static let TimeMachineLogAfterThinning = NSNotification.Name("ie.brianhenryie.timemachinelog.afterthinning")
    static let TimeMachineLogAfterCompletedBackupNoThinning = NSNotification.Name("ie.brianhenryie.timemachinelog.aftercompletedbackupnothinning")

}

@available(macOS 10.13, *)
public class TimeMachineLog: NotificationCenter, LogStreamDelegateProtocol {

    // "static properties are executed lazily by default".
    // i.e. reading of the log file will not begin unless a notification is subscribed to.
    public static let shared = TimeMachineLog()

    private var previousInfoLogs = RecentLogs(maxSize: 3)

    override init() {
        super.init()

        let stream = LogStream(delegate: self)
        stream.listen(subsystem: "com.apple.TimeMachine")
    }

    func newLogEntry(entry logEntry: LogEntry) {

        let logMessage = logEntry.message
        print(logMessage)

        if let captureRange = logMessage.range(of: #"Mountpoint '(/Volumes/.*?)' is still valid"#,
                options: .regularExpression),
           let previousLogMessage = previousInfoLogs.last() {

            let volume = logMessage[captureRange]

            switch previousLogMessage {
            case _ where previousInfoLogs.last()?.contains("Completed backup") ?? false:

                print("\n\nBackup to \(volume) complete.\n\n")

                self.post(name: .TimeMachineLogAfterCompletedBackup, object: nil)
            case _ where previousInfoLogs.get(at: -1)?.starts(with:"Thinning") ?? false:

                print("\n\nBackup to \(volume) and cleanup complete.\n\n")

                self.post(name: .TimeMachineLogAfterThinning, object: nil)
            case _ where previousInfoLogs.get(at: -1)?.starts(with:"Mountpoint") ?? false
                    && previousInfoLogs.get(at: -1)?.starts(with:"Thinning") ?? false:

                print("\n\nBackup to \(volume) complete without cleanup.\n\n")

                self.post(name: .TimeMachineLogAfterCompletedBackupNoThinning, object: nil)
            default:
                print("\(logMessage) message followed: \(previousInfoLogs.last() ?? "nothing")")
                break
            }

        }

        self.post(name: .TimeMachineLogAll, object: nil)

        if( logEntry.logType == .Info ) {
            previousInfoLogs.append(message: String(logMessage))
        }
    }
}


