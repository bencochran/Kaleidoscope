//
//  Created by Ben Cochran on 11/19/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Either
import LLVM

internal func codegenInContext(context: CodegenContext)(codegenable: Codegenable) -> Either<Error, ValueType> {
    return codegenable.codegen(context)
}

internal func attemptCast<T,U>(value: T) -> Either<Error, U> {
    guard let casted = value as? U else {
        return .left(Error(kind: .UnknownError, message: "Unable to cast value of type `\(Mirror(reflecting: value).subjectType)` to `\(U.self)`"))
    }
    return .right(casted)
}
