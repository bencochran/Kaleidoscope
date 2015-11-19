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
        return .left(.codegenError("Unable to cast value of type `\(T.self)` to `\(U.self)`"))
    }
    return .right(casted)
}
