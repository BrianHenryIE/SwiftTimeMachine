//
// Created by Brian Henry on 2/24/23.
//

import Foundation


open class LogStream: Process {

    let delegate: LogStreamDelegateProtocol

    let logParser: LogParser

    init(delegate: LogStreamDelegateProtocol) {
        self.delegate = delegate
        logParser = LogParser()

        super.init()
    }

    // /usr/bin/log stream --predicate 'subsystem == "com.apple.TimeMachine"' --info
    func listen(subsystem: String) {

        let pipe = Pipe()

        standardOutput = pipe

        launchPath = "/usr/bin/log"

//        let predicate = NSPredicate(format: "subsystem == %@", "com.apple.TimeMachine")
        let predicate = NSPredicate(format: "subsystem == %@", subsystem)

        // `--info` is "minimum" log level, I think
        arguments = ["stream", "--info",  "--predicate", predicate.predicateFormat]

//        pipe.fileHandleForReading.readabilityHandler = { (fileHandle) -> Void in
//            let availableData = fileHandle.availableData
//            guard let logLine = String.init(data: availableData, encoding: .utf8) else {
//                return
//            }
//
//            print("\n\n\(logLine)")
//
//            self.delegate.newLogEntry(entry: logParser.parse(logLine: logLine)!)
//        }

        pipe.fileHandleForReading.readabilityHandler = handler

        launch()

        // TODO: Presumably this needs to be run in another thread
        waitUntilExit()
    }

    func handler(fileHandle: FileHandle) -> Void {
        let availableData = fileHandle.availableData
        guard let logLine = String.init(data: availableData, encoding: .utf8) else {
            return
        }

        print("\n\n\(logLine)")

        guard let parsedLogLine = logParser.parse(logLine: logLine) else {
            return
        }

        delegate.newLogEntry(entry: parsedLogLine)
    }

}