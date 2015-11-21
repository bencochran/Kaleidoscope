//
//  Created by Ben Cochran on 11/19/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import LLVM
import KaleidoscopeLang
import Either
import Prelude

extension FunctionExpression : Codegenable {
    func codegen(context: CodegenContext) -> Either<Error, ValueType> {
        return generateFunction(context).map(id)
    }
    
    func generateFunction(context: CodegenContext) -> Either<Error, Function> {
        // Clear scope
        context.clearScope()
        
        return prototype
            .generateFunction(context)
            .flatMap(context.addArguments(prototype.args))
            .flatMap(context.buildBodyOfFunction(body))
    }
}

internal extension CodegenContext {
    private func addArguments(args: [String])(toFunction function: Function) -> Either<Error, Function> {
        return args
            .enumerate()
            .map({ ($1, function.paramAtIndex(UInt32($0))) })
            .map(addValueToScope)
            .compact()
            .map(const(function))
    }
    
    private func buildBodyOfFunction(body: ValueExpression)(function: Function) -> Either<Error, Function> {
        // Create a new basic block to start insertion into.
        let block = function.appendBasicBlock("entry", context: context)
        
        // Position the builder at the end of the block
        builder.positionAtEnd(block: block)
        
        // Generate the body
        guard let codegenableBody = body as? Codegenable else {
            return .left(.codegenError("Body \(body) is not codegenable"))
        }
        let returnValue = codegenableBody.codegen(self).map({ builder.buildReturn(value: $0) })
        
        // Verify the function along the way
        return returnValue &&& verifyFunction(function) >>- const(.right(function))
    }
    
    internal func verifyFunction(function: Function) -> Either<Error, ValueType> {
        guard function.verify() else {
            return .left(.codegenError("Unable to verify `\(function.name ?? "(null)")`"))
        }
        return .right(function)
    }
}
