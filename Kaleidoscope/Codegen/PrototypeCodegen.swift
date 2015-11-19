//
//  Created by Ben Cochran on 11/19/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import LLVM
import KaleidoscopeLang
import Either
import Prelude

extension PrototypeExpression : Codegenable {
    func codegen(context: CodegenContext) -> Either<Error, ValueType> {
        return generateFunction(context).map(id)
    }
    
    func generateFunction(context: CodegenContext) -> Either<Error, Function> {
        return context.getOrBuildPrototype(name, args: args) >>- context.nameArgsForFunction(args)
    }
}


private extension CodegenContext {
    private func nameArgsForFunction(args: [String])(function: Function) -> Either<Error, Function> {
        for (i, argName) in args.enumerate() {
            var arg = function.paramAtIndex(UInt32(i))
            arg.name = argName
        }
        return .right(function)
    }

    private func getExistingPrototype(name: String, args: [String]) -> Either<Error, Function?> {
        guard let function = module.functionByName(name) else {
            return .right(nil)
        }
        // TODO:
//        if !function.isDeclaration {
//            throw "Redefinition of function."
//        }
        if function.paramCount != UInt32(args.count) {
            return .left(.codegenError("Redeclaration of `\(name)` with different number of args."))
        }
        return .right(function)
    }

    private func buildPrototype(name: String, args: [String]) -> Either<Error, Function> {
        let doubleType = RealType.double(inContext: context)
        let paramTypes: [TypeType] = Array(count: args.count, repeatedValue: doubleType)
        let type = FunctionType(returnType: doubleType, paramTypes: paramTypes, isVarArg: false)
        let function = Function(name: name, type: type, inModule: module)
        if function.name != name {
            return .left(.codegenError("Error generating prototype `\(name)`: actually generated `\(function.name ?? "(null)")`"))
        }
        return .right(function)
    }

    /// Attempt to retrieve the current pro
    private func getOrBuildPrototype(name: String, args: [String]) -> Either<Error, Function> {
        return getExistingPrototype(name, args: args)
            .flatMap { existing in
                if let existing = existing {
                    return .right(existing)
                } else {
                    return buildPrototype(name, args: args)
                }
        }
    }
}