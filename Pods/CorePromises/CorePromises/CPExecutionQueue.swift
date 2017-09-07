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

/// The `CPExecutionQueue` protocol may be implemented to create arbitrary execution queues to use when executing
/// promises.
public protocol CPExecutionQueue {
    
    /// Executes the given closure according to the implementation. It is advisable to perform execution
    /// asynchronously to mimic the Promises' desired behavior.
    /// Most of the time, `DispatchQueue` and `CCTransientQueue` should be sufficient.
    ///
    /// - Parameter work: The closure to execute.
    func execute(work: @escaping () -> Void)
}

extension DispatchQueue: CPExecutionQueue {
    
    /// Executes the given closure asynchronously.
    ///
    /// - Parameter work: The closure to execute.
    public func execute(work: @escaping () -> Void) {
        self.async(execute: work)
    }
    
}
