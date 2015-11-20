//
//  Created by Ben Cochran on 11/17/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import KaleidoscopeLang
import Either
import Prelude

struct Analyzer {
    /// Analyzes the sequence of expressions and returns an Error or the array of re-wrapped expressions
    static func analyze<S: SequenceType where S.Generator.Element == Expression>(expressions: S) -> Either<Error, [Expression]> {
        var analyzer = Analyzer()
        return expressions
            .map({ analyzer.analyzeExpression($0) })
            .compact()
    }
    
    /// A mapping of function names to argument count and whether the function is defined (or just forward-declared)
    private var prototypes: [String: (argCount: Int, isDefined: Bool)] = [:]
    
    /// An array of arrays of variables visible at the current state of the analyzer
    private var scopes: [[String]] = []

    /// Analyzes the expression given the current analyzer state and returns an Error or the re-wrapped Expression
    mutating func analyzeExpression(expression: Expression) -> Either<Error, Expression> {
        switch expression {
        case let prototype as PrototypeExpression:
            return self.analyzePrototype(prototype).map(id)
        case let function as FunctionExpression:
            return self.analyzeFunction(function).map(id)
        case let binaryOperator as BinaryOperatorExpression:
            return self.analyzeBinaryOperator(binaryOperator).map(id)
        case let call as CallExpression:
            return self.analyzeCall(call).map(id)
        case let variable as VariableExpression:
            return self.analyzeVariable(variable).map(id)
        case _ as NumberExpression:
            return .right(expression)
        case let main as MainExpression:
            return self.analyzeMain(main).map(id)
        default:
            return .left(.analysisError("Unknown expression type `\(Mirror(reflecting: expression).subjectType)`"))
        }
    }
    
    /// Analyzes the prototype given the current analyzer state and returns an Error or the re-wrapped PrototypeExpression
    mutating func analyzePrototype(prototype: PrototypeExpression) -> Either<Error, PrototypeExpression> {
        if let (existingArgCount, _) = prototypes[prototype.name] {
            if existingArgCount != prototype.args.count {
                return .left(Error(
                    kind: .AnalysisError,
                    message: "`\(prototype.name)` already exists with a different argument count"
                ))
            }
        }
        prototypes[prototype.name] = (argCount: prototype.args.count, isDefined: false)
        return .right(prototype)
    }
    
    /// Analyzes the function given the current analyzer state and returns an Error or the re-wrapped FunctionExpression
    mutating func analyzeFunction(function: FunctionExpression) -> Either<Error, FunctionExpression> {
        if let (existingArgCount, isDefined) = prototypes[function.prototype.name] {
            if isDefined {
                return .left(.analysisError("`\(function.prototype.name)` is already defined"))
            }
            if existingArgCount != function.prototype.args.count {
                return .left(.analysisError("`\(function.prototype.name)` already declared with a different argument count"))
            }
        }
        prototypes[function.prototype.name] = (argCount: function.prototype.args.count, isDefined: true)
        
        scopes.append(function.prototype.args)
        let result = analyzeExpression(function.body)
        scopes.removeLast()
        return result.map(const(function))
    }
    
    /// Analyzes the main function given the current analyzer state and returns an Error or the re-wrapped MainExpression
    mutating func analyzeMain(function: MainExpression) -> Either<Error, MainExpression> {
        if let (existingArgCount, isDefined) = prototypes["main"] {
            if isDefined {
                return .left(.analysisError("`main` is already defined"))
            }
            if existingArgCount != 0 {
                return .left(.analysisError("`main` already declared with a different argument count"))
            }
        }
        prototypes["main"] = (argCount: 0, isDefined: true)

        scopes.append([])
        let result = analyzeExpression(function.body)
        scopes.removeLast()
        return result.map(const(function))
    }

    /// Analyzes the binary operator given the current analyzer state and returns an Error or the re-wrapped BinaryOperatorExpression
    mutating func analyzeBinaryOperator(binaryOperator: BinaryOperatorExpression) -> Either<Error, BinaryOperatorExpression> {
        // TODO check for known operator
        return analyzeExpression(binaryOperator.left)
            &&& analyzeExpression(binaryOperator.right)
            >>- const(.right(binaryOperator))
    }
    
    /// Analyzes the call given the current analyzer state and returns an Error or the re-wrapped CallExpression
    mutating func analyzeCall(call: CallExpression) -> Either<Error, CallExpression> {
        guard prototypes.keys.contains(call.callee) else {
            return .left(.analysisError("`\(call.callee)` is not defined"))
        }
        return call.args.map({ self.analyzeExpression($0) }).compact().map(const(call))
    }
    
    /// Analyzes the variable given the current analyzer state and returns an Error or the re-wrapped VariableExpression
    mutating func analyzeVariable(variable: VariableExpression) -> Either<Error, VariableExpression> {
        guard let scope = scopes.last where scope.contains(variable.name) else {
            return .left(.analysisError("variable `\(variable.name)` not in scope"))
        }
        return .right(variable)
    }
}
