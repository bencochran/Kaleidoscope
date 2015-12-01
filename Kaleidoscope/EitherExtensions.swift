//
//  Created by Ben Cochran on 11/18/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Either
import Prelude

// These are in Either’s upstream, but not released yet and Madness is bringing in Either, so…
extension Either {
    /// Maps `Left` values with `transform`, and re-wraps `Right` values.
    public func mapLeft<V>(@noescape transform: T -> V) -> Either<V, U> {
        return flatMapLeft { .left(transform($0)) }
    }
    
    /// Returns the result of applying `transform` to `Left` values, or re-wrapping `Right` values.
    public func flatMapLeft<V>(@noescape transform: T -> Either<V, U>) -> Either<V, U> {
        return either(
            ifLeft: transform,
            ifRight: Either<V, U>.right)
    }
}

// These are copied from Either
extension EitherType {
    /// Maps `Right` values with `transform`, and re-wraps `Left` values.
    func flatMap<V>(@noescape transform: RightType -> Either<LeftType, V>) -> Either<LeftType, V> {
        return either(ifLeft: Either.left, ifRight: transform)
    }
    
    /// Returns the result of applying `transform` to `Right` values, or re-wrapping `Left` values.
    public func map<V>(@noescape transform: RightType -> V) -> Either<LeftType, V> {
        return flatMap { .right(transform($0)) }
    }
}

/// Returns an Either with a tuple of `left` and `right` values if both are `Right`s, or re-wrapping the earlier `Left`.
/// This operator is defined in Prelude
public func &&& <L: EitherType, R: EitherType where L.LeftType == R.LeftType> (left: L, @autoclosure right: () -> R) -> Either<L.LeftType, (L.RightType, R.RightType)> {
    return left.flatMap { left in right().map { right in (left, right) } }
}


extension SequenceType where Generator.Element : EitherType {
    /// Turns a sequence of `Either<T,U>`s into an `Either<T,[U]>`
    func compact() -> Either<Generator.Element.LeftType, [Generator.Element.RightType]> {
        return reduce(.Right([])) { either, element in
            return (either &&& element).map { $0 + [$1] }
        }
    }
}

extension EitherType where RightType : SequenceType {
    /// Returns the `compact`ed result of applying `transform` to each of the `Right` values or re-wraps `Left`
    func flatMapEach<V>(@noescape transform: RightType.Generator.Element -> Either<LeftType, V>) -> Either<LeftType, [V]> {
        return flatMap { $0.flatMap(transform).compact() }
    }

    /// Maps each `Right` value with `transform`, or re-wraps `Left`.
    func mapEach<V>(@noescape transform: RightType.Generator.Element -> V) -> Either<LeftType, [V]> {
        return flatMapEach { .right(transform($0)) }
    }
}
