//
//  MainExpression.swift
//  Kaleidoscope
//
//  Created by Ben Cochran on 11/19/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import KaleidoscopeLang
import Either

struct MainExpression : TopLevelExpression, Equatable {
    let body: ValueExpression
    init(body: ValueExpression) {
        self.body = body
    }
}

func == (left: MainExpression, right: MainExpression) -> Bool {
    return left.body == right.body
}

func liftMain(expression: Expression) -> Either<Error, Expression> {
    guard let functionExpression = expression as? FunctionExpression
        where functionExpression.prototype.name == "main" else {
            // Pass non-functions and functions not named "main" through
            return .right(expression)
    }
    guard functionExpression.prototype.args.count == 0 else {
        return .left(Error(kind: ErrorKind.UnknownError, message: "`main` cannot take arguments"))
    }
    return .right(MainExpression(body: functionExpression.body))
}
