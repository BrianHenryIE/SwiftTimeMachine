// Execute tmutil with options, return the parsed result.
//
// TODO: Use "host" for ssh/remote execution

import Foundation

open class TmUtil {

    // Usage: tmutil version
    public func version() -> TmVersion? {
        let execResult = execTmUtilAsString(args: ["version"])
        return TmVersion( message: execResult )
    }

    public func destinationInfo() -> TmDestinationInfo? {

        let execResult = execTmUtil(args: ["destinationinfo", "-X"])

        let result = TmDestinationInfoDecoder().decode(from: execResult)

        return result
    }

    private func execTmUtilAsString(args: [String], host: String? = nil) -> String {
        let outputData = execTmUtil(args: args)
        let outputString = String(decoding: outputData, as: UTF8.self)
        return outputString
    }

    private func execTmUtil(args: [String], host: String? = nil) -> Data {

        let outputPipe = Pipe()
        let errorPipe = Pipe()

        let process = Process()

        // https://developer.apple.com/documentation/foundation/process/1407627-standardoutput
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        process.launchPath = "/usr/bin/tmutil"
        process.arguments = args

        process.launch()

        process.waitUntilExit()

        return outputPipe.fileHandleForReading.readDataToEndOfFile()
    }
}
