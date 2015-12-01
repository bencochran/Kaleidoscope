//
//  LibraryCodegen.swift
//  Kaleidoscope
//
//  Created by Ben Cochran on 11/20/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import LLVM
import Either
import Prelude

// MARK: `putchard`

private func declarePutchar(context: CodegenContext) -> Either<Error,Function> {
    let intType = IntType.int32(inContext: context.context)
    let type = FunctionType(returnType: intType, paramTypes: [intType], isVarArg: false)
    let function = Function(name: "putchar", type: type, inModule: context.module)
    if function.name != "putchar" {
        return .left(.codegenError("Error generating prototype `putchar`: actually generated `\(function.name ?? "(null)")`"))
    }
    return .right(function)
}

/// In C, this would be:
///
///   double putchard(double c) {
///     return (double)putchar((int) c);
///   }
func generatePutchard(context: CodegenContext) -> Either<Error, Function> {
    return declarePutchar(context).flatMap { putchar in
        // Create `putchard` declaration
        let doubleType = RealType.double(inContext: context.context)
        let type = FunctionType(returnType: doubleType, paramTypes: [doubleType], isVarArg: false)
        let function = Function(name: "putchard", type: type, inModule: context.module)
        if function.name != "putchard" {
            return .left(.codegenError("Error generating prototype `putchard`: actually generated `\(function.name ?? "(null)")`"))
        }
        
        // Create a new basic block to start insertion into.
        let block = function.appendBasicBlock("entry", context: context.context)
        
        // Position the builder at the end of the block
        context.builder.positionAtEnd(block: block)
        
        let input = function.paramAtIndex(0)

        // Cast the input to an int
        let intType = IntType.int32(inContext: context.context)
        let castedInput = context.builder.buildFPToUI(input, destinationType: intType, name: "tmpinput")
        
        // Build the call to `putchar`
        let result = context.builder.buildCall(putchar, args: [castedInput], name: "tmpcall")
        
        // Cast the result to a double and build the return
        let castedResult = context.builder.buildUIToFP(result, destinationType: doubleType, name: "tmpreturn")
        context.builder.buildReturn(value: castedResult)
        
        // Verify the function along the way
        return context.verifyFunction(function) >>- const(.right(function))
    }
}
