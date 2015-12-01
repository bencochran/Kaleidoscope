//
//  main.swlft
//  Kaleidoscope
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import KaleidoscopeLang
import LLVM
import Either
import Prelude

func compileModule(lines: [String]) -> Either<Error, CodegenContext> {
    let context = CodegenContext(moduleName: "kaleidoscope", context: Context.globalContext)

    return Either.right(lines) &&& generateStandardLibrary(context)
        >>- compile
        >>- const(.right(context))
}

private func generateStandardLibrary(context: CodegenContext) -> Either<Error, CodegenContext> {
    return generatePutchard(context)
        &&& generatePrintd(context)
        >>- const(.right(context))
}

private func compile(lines: [String], inContext context: CodegenContext) -> Either<Error, [ValueType]> {
    return parseLines(lines) >>- Analyzer.analyze >>- codegen(context)
}

private func parseLines(lines: [String]) -> Either<Error, [Expression]> {
    return lines
        .map {
            // Parse each expression
            return parseTopLevelExpression($0)
                // Wrap errors
                .mapLeft(Error.parseError)
                // Cast as Expression
                .map(id)
                // Lift `main` to a MainExpression
                .flatMap(liftMain)
        }
        // Compact the array of `Either`s into a single `Either` of `Array`
        .compact()
}

private func codegen(context: CodegenContext)(expressions: [Expression]) -> Either<Error, [ValueType]> {
    return expressions
        // Attempt to cast each Expression to Codegenable
        .map(attemptCast)
        // Compact the array of `Either`s into a single `Either` of `Array`
        .compact()
        // Perform code generation in the context
        .flatMapEach(codegenInContext(context))
}

func extractModule(context: CodegenContext) -> Either<Error, String> {
    guard let ir = context.module.string else {
        return .left(Error(kind: .CodegenError, message: "Unable to generate IR"))
    }
    return .right(ir)
}

var stdout = OutputStream.Out
var stderr = OutputStream.Err


let lines = [
    "extern putchard(x);",
    "extern printd(x);",
    "extern addThree(a b c);",
    "def main() printd(addThree(1 2 -10.5));",
    "def add(a b) a + b;",
    "def addThree(x y z) add(add(x y) z);"
]

compileModule(lines)
    .flatMap(extractModule)
    .mapLeft { String("Failed: \($0)") }
    .materialize(leftStream: &stderr, rightStream: &stdout)
