// A FIFO queue for Strings
//
// Because the most recent log often needs the context of previous logs,
//
// Created by Brian Henry on 5/21/22.
//
//

import Foundation


struct RecentLogs {

    let maxSize: Int

    // Cannot extend structs.
    var backingArray = Array<String>()

    init(maxSize:Int = 10) {
        self.maxSize = maxSize
    }

    mutating func append(message: String){

        backingArray.append(message)

        if( backingArray.count > maxSize ) {
            // Should we use popFirst or removeFirst?
            _ = backingArray.removeFirst()
        }
    }

    // -1 to get last
    func get(at index: Int) -> String? {

        // |  0 |  1 |  2 |  3 |  4 |  5 |
        // | -6 | -5 | -4 | -3 | -2 | -1 |
        // count = 6

        var vIndex = index

        if( index < 0 ) {
            vIndex = backingArray.count + index
        }

        if( vIndex < 0 || vIndex > backingArray.count ) {
            return nil
        }

        return backingArray[vIndex]
    }

    func last() -> String? {
        return get(at: -1)
    }

}
