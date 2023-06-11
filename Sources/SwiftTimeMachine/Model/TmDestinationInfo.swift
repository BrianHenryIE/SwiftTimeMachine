//
// Created by Brian Henry on 6/9/23.
//

import Foundation

extension TmDestinationInfo.Destination {
        public enum Kind: String, Decodable {
                case local = "Local"
                case network = "Network"
        }
}

extension TmDestinationInfo {
        public struct Destination: Decodable {

                // Name          : 9168227426-F4
                public let name: String
                // Kind          : Local
                public let kind: Kind
                // Mount Point   : /Volumes/9168227426-F4
                public let mountPoint: String?
                // ID            : 511D3A0B-8810-4704-B45B-E2A2FFC26DAE
                public let id: String

                public let lastDestination: IntEncodedBool?

                private enum CodingKeys: String, CodingKey {
                        case kind = "Kind"
                        case id = "ID"
                        case name = "Name"
                        case lastDestination = "LastDestination"
                        case mountPoint = "MountPoint"
                }
        }
}

public struct TmDestinationInfo: Decodable {

        public let destinations: [Destination]

        private enum CodingKeys: String, CodingKey {
                case destinations = "Destinations"
        }
}
