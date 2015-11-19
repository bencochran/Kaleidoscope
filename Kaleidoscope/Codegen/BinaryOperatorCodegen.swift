//
//  BinaryOperatorCodegen.swift
//  Kaleidoscope
//
//  Created by Ben Cochran on 11/19/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import LLVM
import KaleidoscopeLang
import Either
import Prelude

extension BinaryOperatorExpression : Codegenable {
    func codegen(context: CodegenContext) -> Either<Error, ValueType> {
        let left = attemptCast(self.left) >>- codegenInContext(context)
        let right = attemptCast(self.right) >>- codegenInContext(context)
        
        return left &&& right >>- context.generateBinaryOperation(code)
    }
}

private extension CodegenContext {
    func generateBinaryOperation(code: Character)(left: ValueType, right: ValueType) -> Either<Error, ValueType> {
        switch code {
        case "+":
            return .right(builder.buildFAdd(left: left, right: right, name: "addtmp"))
        case "-":
            return .right(builder.buildFSub(left: left, right: right, name: "subtmp"))
        case "*":
            return .right(builder.buildFMul(left: left, right: right, name: "multmp"))
        case "<":
            let result = builder.buildFCmp(LLVMRealULT, left: left, right: right, name: "cmptmp")
            let double = RealType.double(inContext: context)
            return .right(builder.buildUIToFP(result, destinationType: double, name: "booltmp"))
        case let unknown:
            return .left(.codegenError("Unknown binary operator `\(unknown)`"))
        }
    }
}
