//
// Created by Brian Henry on 6/11/23.
//

import Foundation


public struct TmProgress: Decodable {
    public let percent: StringEncodedDouble // = "0.5918951939599612";
    public let timeRemaining: StringEncodedDouble? // = "148.7789304643575";
    public let rawPercent: StringEncodedDouble // "_raw_Percent" = "0.5918951939599612";
    public let rawTotalBytes: Int // "_raw_totalBytes" = 1805307203584;
    public let bytes: Int // = 831418368;
    public let files: Int // = 457;
    public let sizingFreePreflight: IntEncodedBool // = 1;
    public let totalBytes: Int // = 1805307203584;
    public let totalFiles: Int // = 10159895;
}

