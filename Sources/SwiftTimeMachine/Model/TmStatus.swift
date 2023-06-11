//
// Created by Brian Henry on 6/10/23.
//
// Values seem to be sorted alphabetically

import Foundation
import RegexBuilder

extension TmStatus {

    public enum BackUpPhase: String, Decodable {
        case PreparingSourceVolumes = "PreparingSourceVolumes"
        case FindingChanges = "FindingChanges"
        case Copying = "Copying"
    }

}

public struct TmStatus: TmResult, Decodable {

    public let backupPhase: BackUpPhase?
    public let clientID: String // = "com.apple.backupd";
    public let dateOfStateChange: Date? // = "2023-02-27 01:11:08 +0000";
    public let destinationID: String? // UUID? = "8818CBEE-8A5D-4859-A4A7-4B3B7885CFEB";
    public let destinationMountPoint: String? // = "/Volumes/8tb";
    public let fractionDone: Double?
    public let fractionOfProgressBar: StringEncodedDouble? // = "0.9";
    public let percent: Double? // = -1;
    public let progress: TmProgress?
    public let running: IntEncodedBool // = 1;
    public let stopping: IntEncodedBool? // = 0;

}
