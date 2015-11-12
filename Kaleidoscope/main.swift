//
//  main.swlft
//  Kaleidoscope
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Foundation
import KaleidoscopeLang

let ast = KaleidoscopeLang.parse("def add(a b) a + b;")
print(ast)

func llvmError(reason: UnsafePointer<Int8>) {
    // Breakpoint-able error handler
    fatalError(String.fromCString(reason)!)
}
LLVMInstallFatalErrorHandler(llvmError)
