//
//  main.swlft
//  Kaleidoscope
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Foundation
import KaleidoscopeLang

let ast = KaleidoscopeLang.parseTopLevelExpression("def add(a b) a + b")
print(ast)
