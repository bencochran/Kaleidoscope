//
//  Created by Ben Cochran on 11/19/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import KaleidoscopeLang
import Either
import LLVM
import Prelude

extension MainExpression : Codegenable {
    func codegen(context: CodegenContext) -> Either<Error, ValueType> {
        return generateMain(context).map(id)
    }
    
    func generatePrototype(context: CodegenContext) -> Either<Error, Function> {
        return context.buildMainPrototype()
    }
    
    func generateMain(context: CodegenContext) -> Either<Error, Function> {
        // Clear scope
        context.clearScope()
        
        return generatePrototype(context)
            .flatMap(context.buildMainBody(body))
    }
}

extension CodegenContext {
    private func buildMainPrototype() -> Either<Error, Function> {
        let intType = IntType.int32(inContext: context)
        let type = FunctionType(returnType: intType, paramTypes: [], isVarArg: false)
        let function = Function(name: "main", type: type, inModule: module)
        if function.name != "main" {
            return .left(.codegenError("Error generating prototype `main`: actually generated `\(function.name ?? "(null)")`"))
        }
        return .right(function)
    }
    
    private func buildMainBody(body: ValueExpression)(function: Function) -> Either<Error, Function> {
        // Create a new basic block to start insertion into.
        let block = function.appendBasicBlock("entry", context: context)
        
        // Position the builder at the end of the block
        builder.positionAtEnd(block: block)
        
        guard let codegenableBody = body as? Codegenable else {
            return .left(.codegenError("Body \(body) is not codegenable"))
        }
        
        let intType = IntType.int32(inContext: context)
        let returnValue = codegenableBody
            // Generate the body
            .codegen(self)
            // Cast its result to an int
            .map({ builder.buildFPToUI($0, destinationType: intType, name: "casttmp") })
            // Build the return
            .map({ builder.buildReturn(value: $0) })
        
        // Verify the function along the way
        return returnValue &&& verifyFunction(function) >>- const(.right(function))
    }
}
