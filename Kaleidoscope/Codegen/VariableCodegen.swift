//
//  Created by Ben Cochran on 11/19/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import LLVM
import KaleidoscopeLang
import Either
import Prelude

extension VariableExpression : Codegenable {
    func codegen(context: CodegenContext) -> Either<Error, ValueType> {
        return context.valueInScope(name)
    }
}
