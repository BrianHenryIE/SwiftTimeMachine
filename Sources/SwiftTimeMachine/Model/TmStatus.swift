//
// Created by Brian Henry on 6/10/23.
//
// Values seem to be sorted alphabetically

import Foundation
import RegexBuilder

public struct TmStatus: TmResult, CustomStringConvertible {

    public struct Progress {
        public let percent: Double // = "0.5918951939599612";
        public let timeRemaining: Double // = "148.7789304643575";
        public let rawPercent: Double // "_raw_Percent" = "0.5918951939599612";
        public let rawTotalBytes: Int // "_raw_totalBytes" = 1805307203584;
        public let bytes: Int // = 831418368;
        public let files: Int // = 457;
        public let sizingFreePreflight: Bool // = 1;
        public let totalBytes: Int // = 1805307203584;
        public let totalFiles: Int // = 10159895;
    }

    public enum BackUpPhase: String {
        case PreparingSourceVolumes = "PreparingSourceVolumes"
        case FindingChanges = "FindingChanges"
        case Copying = "Copying"
    }

    public let backupPhase: BackUpPhase?
    public let clientId: String // = "com.apple.backupd";
    public let dateOfStateChange: Date? // = "2023-02-27 01:11:08 +0000";
    public let destinationMountPoint: String? // = "/Volumes/8tb";
    public let percent: Double? // = -1;
    public let running: Bool // = 1;

    public init?(message: String) {

        let backupPhase = Reference(BackUpPhase?.self)
        let clientId = Reference(Substring.self)
        let dateOfStateChange = Reference(Date?.self)
        let destinationMountPoint = Reference(String?.self)
        let percent = Reference(Double?.self)
        let running = Reference(Bool.self)

        let regex = Regex {

            "Backup session status:\u{A}{"

            // In case there are unaccounted for properties.
            ZeroOrMore(.reluctant) {
                .any
            }

            // `    BackupPhase = PreparingSourceVolumes;`
            Optionally {
                "\u{A}    BackupPhase = "
                TryCapture(as: backupPhase) {
                    OneOrMore(.word)
                } transform: {
                    TmStatus.BackUpPhase(rawValue: String($0))
                }
                ";"

                // In case there are unaccounted for properties.
                ZeroOrMore(.reluctant) {
                    .any
                }
            }

            // ClientID is alway present.
            // ClientID = "com.apple.backupd";
            "\u{A}    ClientID = \""
            Capture(as: clientId) {
                ZeroOrMore(.reluctant) {
                    .any
                }
            }
            "\";"

            Optionally {
                // In case there are unaccounted for properties.
                ZeroOrMore(.reluctant) {
                    .any
                }
            }

            // `    DateOfStateChange = "2023-02-27 01:08:48 +0000";
            Optionally {
                "\u{A}    DateOfStateChange = \""
                Capture(as: dateOfStateChange) {
                    Repeat(.digit, count: 4)
                    "-"
                    Repeat(.digit, count: 2)
                    "-"
                    Repeat(.digit, count: 2)
                    " "
                    Repeat(.digit, count: 2)
                    ":"
                    Repeat(.digit, count: 2)
                    ":"
                    Repeat(.digit, count: 2)
                    " +"
                    Repeat(.digit, count: 4)
                } transform: {

                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [
                        .withDay,
                        .withMonth,
                        .withYear,
                        .withTime,
                        .withTimeZone,
                        .withColonSeparatorInTime,
                        .withDashSeparatorInDate,
                        .withInternetDateTime,
                        .withSpaceBetweenDateAndTime
                    ]

                    let captured = String($0)
                    return dateFormatter.date(from: captured)
                }
                "\";"

                // In case there are unaccounted for properties.
                ZeroOrMore(.reluctant) {
                    .any
                }
            }
            // `    Percent = "-1";`
            Optionally {
                "\u{A}    Percent = \""
                TryCapture(as: percent) {
                    Regex {
                        Optionally {
                            "-"
                        }
                        OneOrMore(.digit)
                    }
                } transform: {
                    Double($0)
                }
                "\";"

                // In case there are unaccounted for properties.
                ZeroOrMore(.reluctant) {
                    .any
                }
            }

            // Running is always present.
            // `    Running = 0;`
            "\u{A}    Running = "
            TryCapture(as: running) {
                One(.digit)
            } transform: {
                String($0) == "1"
            }
            ";"


            // In case there are unaccounted for properties.
            ZeroOrMore(.reluctant) {
                .any
            }
        }
        .anchorsMatchLineEndings()

            return nil
        }

        self.backupPhase = matches[backupPhase] ?? nil

        self.clientId = String(matches[clientId])

        self.dateOfStateChange = matches[dateOfStateChange] ?? nil


//            self.destinationMountPoint = matches[destinationMountPoint]
            self.destinationMountPoint = nil

        self.percent = matches[percent] ?? nil

        self.running = matches[running]
    }


    public var description: String {
        var desc = "Backup session status:\n"

        return desc
    }
}