//
//  Created by Ben Cochran on 11/17/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import LLVM
import Either

/// Defined a type that can generate LLVM commands into the given context
protocol Codegenable {
    /// Generate the value’s LLVM IR representation into the given context and return the result
    /// (or an error if there is one)
    func codegen(context: CodegenContext) -> Either<Error, ValueType>
}
