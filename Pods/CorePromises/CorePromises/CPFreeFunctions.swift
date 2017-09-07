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

/// Returns the given promise to improve code appearance.
///
/// - Parameter execute: The closure to execute, returning the promise to use.
/// - Returns: The returned promise.
public func promise<ResultType>(_ execute: () -> CPPromise<ResultType>) -> CPPromise<ResultType> {
    return execute()
}

/// Waits for all promises to fulfill and returns an array of the fulfilled values once all values have arrived.
/// The resulting promise is rejected as soon as one of the given promises fails.
///
/// - Parameter promises: The promises to fulfill simultaneously.
/// - Returns: A promise with carrying all returned values in an array.
public func promiseAll<T>(_ promises: CPPromise<T>...) -> CPPromise<[T]> {
    return promiseAll(promises)
}

/// Waits for all promises to fulfill and returns an array of the fulfilled values once all values have arrived.
/// The resulting promise is rejected as soon as one of the given promises fails.
///
/// - Parameter promises: The promises to fulfill simultaneously.
/// - Returns: A promise with carrying all returned values in an array.
public func promiseAll<T>(_ promises: [CPPromise<T>]) -> CPPromise<[T]> {
    guard !promises.isEmpty else {
        return CPPromise(value: [])
    }
    return CPPromise { resolve, reject in
        promises.forEach { promise in
            promise
                .then { value in
                    if !promises.contains(where: { !$0.isFulfilled }) {
                        resolve(promises.flatMap { $0.value })
                    }
                }.catch { error in
                    reject(error)
            }
        }
    }
}

/// Delays the execution of the given closure by the given delay and dispatches the execution to the given queue.
///
/// - Parameters:
///   - delay: The seconds to wait before executing the given closure.
///   - queue: The queue on which to execute the given closure. The default is set to `DispatchQueue.main`.
///   - work:  The closure to execute after the given delay has expired.
public func delay(_ seconds: TimeInterval, on queue: DispatchQueue = DispatchQueue.main,
                  execute work: @escaping () -> Void) {
    queue.asyncAfter(deadline: DispatchTime.now() + seconds, execute: work)
}
