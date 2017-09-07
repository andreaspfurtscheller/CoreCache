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

/// The `CPTransientQueue` executes its work iff it has not been invalidated. This is especially useful when using
/// promises in combination with e.g. table views where cells are reused and multiple promises would modify the same
/// cell.
public final class CPTransientQueue: CPExecutionQueue {
    
    private var isValid = true
    private let queue: DispatchQueue
    
    /// Initializes the transient queue with the given dispatch queue. Executions are performed asynchronously on the
    /// given dispatch queue.
    public init(_ queue: DispatchQueue) {
        self.queue = queue
    }
    
    /// Executes the given closure asynchronously on the dispatch queue, handed in the initializer, iff the queue has
    /// not been invalidated yet. Otherwise, it does nothing.
    ///
    /// - Parameter work: The closure to execute.
    public func execute(work: @escaping () -> Void) {
        guard isValid else {
            return
        }
        queue.async(execute: work)
    }
    
    /// Invalidates the queue. Afterwards, no more operations can be performed on the queue and it is not possible to
    /// re-validate it.
    public func invalidate() {
        isValid = false
    }
    
}
