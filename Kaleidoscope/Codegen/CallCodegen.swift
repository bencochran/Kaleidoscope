//
//  Created by Ben Cochran on 11/19/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import LLVM
import KaleidoscopeLang
import Either
import Prelude

extension CallExpression : Codegenable {
    func codegen(context: CodegenContext) -> Either<Error, ValueType> {
        return generateCall(context).map(id)
    }
    
    func generateCall(context: CodegenContext) -> Either<Error, CallInstruction> {
        return context.getPrototypeNamed(callee, argCount: UInt32(args.count))
            &&& context.generateValues(args)
            >>- context.generateCall
    }
}

private extension CodegenContext {
    func getPrototypeNamed(name: String, argCount: UInt32) -> Either<Error, Function> {
        return prototypeNamed(name)
            .flatMap { function in
                guard function.paramCount == argCount else {
                    return .left(.codegenError("Incorrect number of arguments passed to `\(name)`"))
                }
                return .right(function)
            }
    }
    
    func generateValues(expressions: [ValueExpression]) -> Either<Error, [ValueType]> {
        return expressions
            .map(attemptCast)
            .compact()
            .flatMapEach(codegenInContext(self))
    }
    
    func generateCall(callee: Function, args: [ValueType]) -> Either<Error, CallInstruction> {
        return .right(builder.buildCall(callee, args: args, name: "calltmp"))
    }
}
