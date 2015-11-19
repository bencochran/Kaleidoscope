# Kaleidoscope

This is an implementation of (some of) the language from the [LLVM Kaleidoscope tutorial][kaleidoscope]. 

The project itself does its parsing with [KaleidoscopeLang][kaleidoscope-lang] and codegen using
[LLVM.swift][llvm-swift].

## Getting it running

1. Build LLVM (currently tested with 3.6.2). Homebrew is the easiest way to do this: `brew install llvm`

1. Clone the repository and its submodules

1. In `Carthage/Checkouts/LLVM/LLVM.xcconfig`, set `LLVM_PREFIX` to be the prefix used when building `LLVM`.
   For homebrew this will typically be `/usr/local/Cellar/llvm/3.6.2`, for you it may be `/usr/local` or
   similar depending on your setup.

1. Run!

## Limitations

* There’s no way to run the resulting LLVM IR code because there’s no way to represent `main`. See
  [#4][issue-main].

* There’s no JIT like the Kaleidoscope tutorial has.

* This currently only implements up to [Chapter 4][chapter-4] of the Kaleidoscope tutorial



[kaleidoscope]: http://llvm.org/docs/tutorial/
[kaleidoscope-lang]: https://github.com/bencochran/KaleidoscopeLang
[llvm-swift]: https://github.com/bencochran/LLVM.swift
[issue-main]: https://github.com/bencochran/Kaleidoscope/issues/4
[chapter-4]: http://llvm.org/docs/tutorial/LangImpl4.html
