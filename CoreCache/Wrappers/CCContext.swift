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

import CoreData

/// `CCContext` provides a wrapper for a `NSManagedObjectContext`. The publicly given functions provide basic
/// functionality that is mostly sufficient. A `CCContext` may only be obtained from a `CCManager`.
public final class CCContext {
    
    internal let objectContext: NSManagedObjectContext
    
    internal init(context: NSManagedObjectContext) {
        self.objectContext = context
    }
    
    /// Saves the context, possibly not writing anything to disk, in case the context is a child context.
    ///
    /// - Note: Listen for the `CCErrorNotification.saveDidFail` notification to respond to any errors that may occur
    ///         during the save.
    public func save() {
        CCUtility.save(objectContext)
    }
    
    /// Writes the changes in this context to disk by successively calling save on `self` and all parent contexts.
    ///
    /// - Note: Listen for the `CCErrorNotification.saveDidFail` notification to respond to any errors that may occur
    ///         during the write. There is no possibility to be notified of the exact context in which saving failed.
    public func write() {
        save()
        var current = objectContext
        while let parent = current.parent {
            CCUtility.save(parent)
            current = parent
        }
    }
    
    /// Asynchronously executes the given closure on the queue of the associated context.
    ///
    /// - Parameter work: The closure to execute asynchronously.
    public func async(_ work: @escaping () -> Void) {
        objectContext.perform(work)
    }
    
    /// Discards all changes associated with the context. The state is thus resetted to the state of the last call to
    /// `save`.
    public func undo() {
        objectContext.rollback()
    }
    
}
