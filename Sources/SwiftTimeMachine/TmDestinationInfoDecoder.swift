//
// Created by Brian Henry on 6/11/23.
//
// Mutes errors

import Foundation

public class TmDestinationInfoDecoder: PropertyListDecoder {
    public func decode(from data: Data) -> TmDestinationInfo? {
        try? super.decode(TmDestinationInfo.self, from: data)
    }
}
