//
//  Created by Ben Cochran on 11/19/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import LLVM
import KaleidoscopeLang
import Either
import Prelude

extension NumberExpression : Codegenable {
    typealias Result = RealConstant
    
    func codegen(context: CodegenContext) -> Either<Error, ValueType> {
        return context.generateConstant(value).map(id)
    }
}

private extension CodegenContext {
    func generateConstant(value: Double) -> Either<Error, RealConstant> {
        let doubleType = RealType.double(inContext: context)
        return .right(RealConstant.type(doubleType, value: value))
    }
}
