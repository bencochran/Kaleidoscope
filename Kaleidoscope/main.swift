//
//  main.swlft
//  Kaleidoscope
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Foundation
import KaleidoscopeLang
import Either


let lines = [
    "extern addThree(a b c);",
    "def add(a b) a + b;",
    "def addThree(x y z) add(add(x y) z);"
]

let result = lines
    // Parse each line and map errors to the correct type
    // This is a crazier way to do this: (requires a `flip :: (a -> b -> c) -> b -> a -> c`)
    //    .map(parseTopLevelExpression >>> Either<KaleidoscopeLang.Error,TopLevelExpression>.mapLeft |> flip <| Error.parseError)
    .map { parseTopLevelExpression($0).mapLeft(Error.parseError).map({ $0 as Expression }) }
    // Compact the array of `Either`s into a single `Either` of `Array`
    .compact()
    // Analize the expressions
    .flatMap(Analyzer.analyze)

if case let .Left(error) = result {
    print("Failed: \(error)")
    exit(1)
} else {
    print("Success!")
    exit(0)
}
