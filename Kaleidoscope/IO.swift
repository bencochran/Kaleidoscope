//
//  Created by Ben Cochran on 11/19/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Foundation

enum OutputStream {
    case Out
    case Err
    case Null
}

extension OutputStream : OutputStreamType {
    func write(string: String) {
        let handle: NSFileHandle
        switch self {
        case .Out:
            handle = .fileHandleWithStandardOutput()
        case .Err:
            handle = .fileHandleWithStandardError()
        case .Null:
            handle = .fileHandleWithNullDevice()
        }
        handle.writeData(string.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
}
