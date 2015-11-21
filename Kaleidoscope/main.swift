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

var stdout = OutputStream.Out
var stderr = OutputStream.Err

let context = CodegenContext(moduleName: "kaleidoscope", context: Context.globalContext)

let lines = [
    "extern addThree(a b c);",
    "def main() addThree(1 2 3);",
    "def add(a b) a + b;",
    "def addThree(x y z) add(add(x y) z);"
]

let result = lines
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
    // Analize the expressions
    .flatMap(Analyzer.analyze)
    // Attempt to cast each Expression to Codegenable
    .flatMapEach(attemptCast)
    // Perform code generation in the context
    .flatMapEach(codegenInContext(context))

if case let .Left(error) = result {
    print("Failed: \(error)", toStream: &stderr)
    exit(1)
}

guard let ir = context.module.string else {
    print("Failed to generate IR", toStream: &stderr)
    exit(1)
}

print(ir, toStream: &stdout)
