//
//  Created by Ben Cochran on 11/18/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import KaleidoscopeLang

public enum ErrorKind {
    case ParseError(KaleidoscopeLang.Error)
    case AnalysisError
    case CodegenError
    case UnknownError
}

public struct Error : ErrorType {
    public let kind: ErrorKind
    public let message: String
    
    public init(kind: ErrorKind, message: String) {
        self.kind = kind
        self.message = message
    }
}

extension Error : CustomStringConvertible {
    public var description: String {
        if message.characters.count > 0 {
            return "\(kind): \(message)"
        } else {
            return "\(kind)"
        }
    }
}

extension Error {
    public static func parseError(error: KaleidoscopeLang.Error) -> Error {
        return Error(kind: .ParseError(error), message: "")
    }
    public static func analysisError(message: String) -> Error {
        return Error(kind: .AnalysisError, message: message)
    }
    public static func codegenError(message: String) -> Error {
        return Error(kind: .CodegenError, message: message)
    }
}
