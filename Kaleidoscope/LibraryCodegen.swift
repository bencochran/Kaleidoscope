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

// MARK: `printd`

private func declarePrintf(context: CodegenContext) -> Either<Error,Function> {
    let int32Type = IntType.int32(inContext: context.context)
    let int8Type = IntType.int8(inContext: context.context)
    let pointerType = PointerType(type: int8Type, addressSpace: 0) // TODO: address space ?
    let type = FunctionType(returnType: int32Type, paramTypes: [pointerType], isVarArg: true)
    let function = Function(name: "printf", type: type, inModule: context.module)
    if function.name != "printf" {
        return .left(.codegenError("Error generating prototype `printf`: actually generated `\(function.name ?? "(null)")`"))
    }
    return .right(function)
}

/// In C, this would be:
///
///   double printd(double d) {
///     return (double)printf("%f", d);
///   }
func generatePrintd(context: CodegenContext) -> Either<Error, Function> {
    return declarePrintf(context).flatMap { printf in
        // Create format string constant: "%f"
        let formatConstant = context.builder.buildGlobalString("%f", name: "format")
        
        // Create printd declaration
        let doubleType = RealType.double(inContext: context.context)
        let type = FunctionType(returnType: doubleType, paramTypes: [doubleType], isVarArg: false)
        let function = Function(name: "printd", type: type, inModule: context.module)
        if function.name != "printd" {
            return .left(.codegenError("Error generating prototype `printd`: actually generated `\(function.name ?? "(null)")`"))
        }

        // Create a new basic block to start insertion into.
        let block = function.appendBasicBlock("entry", context: context.context)
        
        // Position the builder at the end of the block
        context.builder.positionAtEnd(block: block)
        
        let input = function.paramAtIndex(0)
        
        // Build an array of [0, 0] as constants
        let int32Type = IntType.int32(inContext: context.context)
        let indices: [ValueType] = [IntConstant.type(int32Type, value: 0, shouldSignExtend: false), IntConstant.type(int32Type, value: 0, shouldSignExtend: false)]
        
        // Get pointer to the format constant
        let format = context.builder.buildInBoundsGEP(formatConstant, indices: indices, name: "tmpptr")
        
        // Call `printf`
        let result = context.builder.buildCall(printf, args: [format, input], name: "tmpcalll")
        
        // Cast the result to a double and build the return
        let castedResult = context.builder.buildUIToFP(result, destinationType: doubleType, name: "tmpreturn")
        context.builder.buildReturn(value: castedResult)
        
        // Verify the function along the way
        return context.verifyFunction(function) >>- const(.right(function))
    }
}
