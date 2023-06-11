//
// Created by Brian Henry on 6/9/23.
//

import Foundation

extension TmDestinationInfo {
        struct Destination: Decodable {

                // Name          : 9168227426-F4
                let name: String
                // Kind          : Local
                let kind: String
                // Mount Point   : /Volumes/9168227426-F4
                let mountPoint: String?
                // ID            : 511D3A0B-8810-4704-B45B-E2A2FFC26DAE
                let id: String

                let lastDestination: IntEncodedBool?

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

        let destinations: [Destination]

        private enum CodingKeys: String, CodingKey {
                case destinations = "Destinations"
        }
}
