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

/// A promise according to JavaScript's A+ specification. The main difference to JavaScript's promises is that all
/// `catch` block are called once an error occurs, not only the next one. It is furthermore not possible to "recover"
/// from an error, meaning that there is now way of entering a `then` block after an error has occured.
///
/// A promise may be fulfilled or rejected. `then` blocks are called upon fulfillment, `catch` blocks upon rejection,
/// `always` blocks are called in either case. Each promise may be associated with arbitrarily many `then`, `catch`
/// and `always` blocks. Once a promise is fulfilled or rejected, it cannot change its state again and does not
/// call any more handlers.
///
/// `CPPromise` is a thread-safe class as it is primarily useful in multi-threaded environments.
public final class CPPromise<ResultType> {
    
    private let lockingQueue = DispatchQueue(label: "lock", qos: .userInitiated)
    internal var state: CPPromiseState<ResultType> = .pending
    internal lazy var callbacks: [CPPromiseCallback<ResultType>] = []
    internal let executionBlock: (_ fulfill: @escaping (ResultType) -> Void,
    _ reject: @escaping (Error) -> Void) throws -> Void
    
    internal var isFulfilled: Bool {
        if case .fulfilled(_) = self.state {
            return true
        }
        return false
    }
    
    internal var isPending: Bool {
        if case .pending = self.state {
            return true
        }
        return false
    }
    
    internal var value: ResultType? {
        if case .fulfilled(let value) = self.state {
            return value
        }
        return nil
    }
    
    /// Initializes a promise which is about to be rejected with the given error.
    /// Use the `CPError.failingPromise` error if you do not want to provide any further information.
    ///
    /// - Parameter error: The error to cause the promise to fail.
    public convenience init(error: Error) {
        self.init { resolve, reject in
            reject(error)
        }
    }
    
    /// Initializes a promise which is about to be fulfilled with the given value.
    ///
    /// - Parameter value: The value which the promise is resolved with.
    public convenience init(value: ResultType) {
        self.init { resolve, reject in
            resolve(value)
        }
    }
    
    /// Initializes a promise which is fulfilled or rejected according to the given closure. The closure may throw
    /// upon which the promise is rejected.
    ///
    /// - Parameters:
    ///   - queue:   The queue on which to execute the given closure. The default is set to `DispatchQueue.global(qos:
    ///              .userInitiated)`.
    ///   - execute: The closure to execute: The first parameter provides a function to fulfill the promise, given the
    ///              promised value, the second parameter provides a function to reject the promise, given an error.
    ///              Calls to one of the closures after one of these has been executed has no effect at all.
    public init(queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
                _ execute: @escaping (_ fulfill: @escaping (ResultType) -> Void,
        _ reject: @escaping (Error) -> Void) throws -> Void) {
        self.executionBlock = execute
        queue.async {
            do {
                try execute(self.fulfill(_:), self.reject(_:))
            } catch let error {
                self.reject(error)
            }
        }
    }
    
    private func fulfill(_ result: ResultType) {
        guard case .pending = self.state else {
            return
        }
        updateState(to: .fulfilled(result))
    }
    
    private func reject(_ error: Error) {
        guard case .pending = self.state else {
            return
        }
        updateState(to: .rejected(error))
    }
    
    /// Executes the given callback on the given queue as the promise is fulfilled.
    ///
    /// - Parameters:
    ///   - executionQueue: The queue to execute the given callback. The default is set to `DispatchQueue.main`.
    ///   - onFulfilled:    The callback to execute with the value which the promise was resolved with. The closure
    ///                     returns another promise.
    /// - Returns: A new promise which fulfilled as the closure's returned promise is fulfilled or rejected as the
    ///            given closure throws or the closure's returned promise is rejected.
    @discardableResult
    public func then<NewResultType>(on executionQueue: CPExecutionQueue = DispatchQueue.main,
                                    _ onFulfilled: @escaping (ResultType) throws -> CPPromise<NewResultType>) -> CPPromise<NewResultType> {
        return CPPromise<NewResultType> { resolve, reject in
            let handler = { (value: ResultType) in
                do {
                    let result = try onFulfilled(value)
                    let callback = CPPromiseCallback(executionQueue: executionQueue,
                                                     onFulfilled: { value in resolve(value) },
                                                     onRejected: { error in reject(error) })
                    result.addCallback(callback)
                } catch let error {
                    reject(error)
                }
            }
            let callback = CPPromiseCallback<ResultType>(executionQueue: executionQueue, onFulfilled: handler,
                                                         onRejected: { error in reject(error) })
            self.addCallback(callback)
        }
    }
    
    /// Executes the given callback on the given queue as the promise is fulfilled.
    ///
    /// - Parameters:
    ///   - executionQueue: The queue to execute the given callback. The default is set to `DispatchQueue.main`.
    ///   - onFulfilled:    The callback to execute with the value which the promise was resolved with. The closure
    ///                     returns another value.
    /// - Returns: A new promise which fulfilled as the closure returns a promise or rejected as the given closure
    ///            throws.
    @discardableResult
    public func then<NewResultType>(on executionQueue: CPExecutionQueue = DispatchQueue.main,
                                    _ onFulfilled: @escaping (ResultType) throws -> NewResultType) -> CPPromise<NewResultType> {
        return then(on: executionQueue) { value -> CPPromise<NewResultType> in
            do {
                return CPPromise<NewResultType>(value: try onFulfilled(value))
            } catch let error {
                return CPPromise<NewResultType>(error: error)
            }
        }
    }
    
    /// Executes the given error handler on the given queue as the promise is rejected.
    ///
    /// - Parameters:
    ///   - executionQueue: The queue to execute the given handler. The default is set to `DispatchQueue.main`.
    ///   - onRejected:     The error handler to execute with the error that caused the promise to be rejected. The
    ///                     handler may not return any value. However, it may convert the error it was handed by
    ///                     throwing a different error that is received by the subsequent error handler. If it does not
    ///                     throw an error, the subsequent error handler is handed the exact same error.
    /// - Returns: The same promise as `self`, associated with the given error handler.
    @discardableResult
    public func `catch`(on executionQueue: CPExecutionQueue = DispatchQueue.main,
                        _ onRejected: @escaping (Error) throws -> Void) -> CPPromise<ResultType> {
        return CPPromise<ResultType> { resolve, reject in
            let handler = { (error: Error) in
                do {
                    try onRejected(error)
                    reject(error)
                } catch let err {
                    reject(err)
                }
            }
            let callback = CPPromiseCallback<ResultType>(executionQueue: executionQueue,
                                                         onFulfilled: { value in resolve(value) },
                                                         onRejected: handler)
            self.addCallback(callback)
        }
    }
    
    /// Executes the given closure on the given queue as the promise is either resolved or rejected.
    ///
    /// - Parameters:
    ///   - executionQueue: The queue to execute the closure. The default is set to `DispatchQueue.main`.
    ///   - work:           The closure to execute as the promise is either resolved or rejected. The closure takes
    ///                     no parameters and returns no value.
    /// - Returns: The same promise as `self`, associated with the given closure on any callback.
    @discardableResult
    public func always(on executionQueue: CPExecutionQueue = DispatchQueue.main,
                       _ work: @escaping () -> Void) -> CPPromise<ResultType> {
        let callback = CPPromiseCallback<ResultType>(executionQueue: executionQueue, onFulfilled: { _ in work() },
                                                     onRejected: { _ in work() })
        self.addCallback(callback)
        return self
    }
    
    /// Rejects the promise after the given timeout. If the promise is fulfilled or rejected in the meantime, the
    /// call to this function has no effect.
    ///
    /// - Parameter timeout: The time interval in seconds after which the promise is rejected.
    /// - Returns: A new promise which is rejected with the `CPError.timeout` error after the given timeout in case
    ///            `self` has not been resolved or rejected in the meantime.
    @discardableResult
    public func timeout(after timeout: TimeInterval) -> CPPromise<ResultType> {
        return CPPromise<ResultType> { resolve, reject in
            self.then(resolve).catch(reject)
            delay(timeout) {
                reject(CPError.timeout)
            }
        }
    }
    
    /// Retries fulfilling `self` at most `times` times. If the promise is not fulfilled after `times` executions,
    /// the promise is rejected.
    ///
    /// - Parameters:
    ///   - times: The number of times to retry fulfilling `self`. Passing 0 causes the promise to always fail with the
    ///            `CPError.retryEnded` error, passing 1 causes the call to have no effect besides returing
    ///            `CPError.retryEnded` in case `self` is rejected.
    ///   - delay: The time interval to wait before retrying to fulfill the promise again. The default is set to 0.
    /// - Returns: A new promise which is fulfilled in case `self` can be fulfilled in `times` executions with `delay`
    ///            seconds between subsequent attempts. Otherwise, the promise is rejected with the
    ///            `CPError.retryEnded` error.
    @discardableResult
    public func retry(_ times: Int, delay: TimeInterval = 0) -> CPPromise<ResultType> {
        return CPPromise<ResultType>.retry(max(times - 1, 0), delay: delay,
                                           generate: { CPPromise(self.executionBlock) })
    }
    
    private static func retry(_ times: Int, delay: TimeInterval = 0,
                              generate: @escaping () -> CPPromise<ResultType>) -> CPPromise<ResultType> {
        if times == 0 {
            return CPPromise<ResultType>(error: CPError.retryEnded)
        }
        return CPPromise<ResultType> { resolve, reject in
            generate().then(resolve)
                .catch { error in
                    CorePromises.delay(delay) {
                        retry(times - 1, delay: delay, generate: generate).then(resolve).catch(reject)
                    }
            }
        }
    }
    
    private func updateState(to newState: CPPromiseState<ResultType>) {
        lockingQueue.sync {
            self.state = newState
        }
        fireCallbacksIfNeeded()
    }
    
    private func addCallback(_ callback: CPPromiseCallback<ResultType>) {
        lockingQueue.async {
            self.callbacks.append(callback)
        }
        fireCallbacksIfNeeded()
    }
    
    private func fireCallbacksIfNeeded() {
        lockingQueue.async {
            if case .pending = self.state {
                return
            }
            self.callbacks.forEach { callback in
                switch self.state {
                case .fulfilled(let value):
                    callback.executionQueue.execute {
                        callback.onFulfilled(value)
                    }
                case .rejected(let error):
                    callback.executionQueue.execute {
                        callback.onRejected(error)
                    }
                default: break
                }
            }
            self.callbacks = []
        }
    }
}

extension CPPromise {
    
    /// Returns a void promise that is usually used to notify the caller of a function that a certain operation has
    /// finished successfully but who is not interested in any return value or there is no return value.
    ///
    /// - Returns: The void promise.
    public func notify() -> CPPromise<Void> {
        return self.then { _ in return }
    }
}

