//
//  Created by Ben Cochran on 11/17/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import LLVM
import KaleidoscopeLang
import Either

class CodegenContext {
    let module: Module
    let builder: Builder
    let context: Context
    
    private var scope: [String:ValueType] = [:]
    private var prototypes: [String:PrototypeExpression] = [:]
    
    init(moduleName: String, context: Context) {
        self.context = context
        module = Module(name: moduleName, context: context)
        builder = Builder(inContext: context)
    }
    
    func prototypeNamed(name: String) -> Either<Error, Function> {
        guard let proto = module.functionByName(name) else {
            return .left(.codegenError("No prototype named \(name)"))
        }
        return .right(proto)
    }
    
    // MARK: Scope
    
    func clearScope() {
        self.scope = [:]
    }
    
    func valueInScope(name: String) -> Either<Error, ValueType> {
        guard let value = scope[name] else {
            return .left(.codegenError("No value in scope named `\(name)`"))
        }
        return .right(value)
    }
    
    func addValueToScope(name: String, value: ValueType) -> Either<Error, ValueType> {
        guard !scope.keys.contains(name) else {
            return .left(.codegenError("Value already declared in scope: `\(name)`"))
        }
        scope[name] = value
        return .right(value)
    }
}
