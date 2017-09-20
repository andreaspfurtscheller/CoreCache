// MIT License
//
// Copyright (c) 2017 Oliver Borchert (borchero@in.tum.de)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

/// The `some` function returns a value in case the given optional wraps a value and throws an exception otherwise,
/// as this behavior is desirable to minimize code size in some cases.
///
/// - Throws: In case the given value does not wrap a value.
/// - Returns: An unwrapped value in case the given optional was wrapping a value.
@available(*, deprecated, message: "Use `some` function on the optional directly.")
@inline(__always)
public func some<T>(_ value: T?) throws -> T {
    switch value {
    case .none:
        throw CUError.unwrappingFailed
    case .some(let value):
        return value
    }
}

/// Rounds an integer to the next number x that is greater
/// or equal than `arg` and divideable by `to`.
///
/// - Parameters:
///   - arg: The value to round.
///   - to: The value to round up to. Needs to be greater 0.
/// - Returns: The round up value.
public func ceil(_ arg: Int, to: Int) -> Int {
    assert(to > 0)
    if arg < 0 {
        return -floor(-arg, to: to)
    }
    let modulo = arg % to
    if modulo == 0 {
        return arg
    }
    return arg + to - modulo
}

/// Rounds an integer to the next number x that is smaller
/// or equal than `arg` and divideable by `to`.
///
/// - Parameters:
///   - arg: The value to round.
///   - to: The value to round up down. Needs to be greater 0.
/// - Returns: The round down value.
public func floor(_ arg: Int, to: Int) -> Int {
    assert(to > 0)
    if arg < 0 {
        return -ceil(-arg, to: to)
    }
    let modulo = arg % to
    return arg - modulo
}
