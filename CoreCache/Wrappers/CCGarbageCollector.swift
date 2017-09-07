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

/// The `CCGarbageCollector` is used to delete objects that conform to the `CCDiscardable` protocol and are associated
/// with a context.
/// A garbage collector may only be obtained by calling `garbageCollector` on a `CCManager`.
@available(iOS 10.0, *)
public final class CCGarbageCollector {
    
    private let manager: CCManager
    
    internal init(manager: CCManager) {
        self.manager = manager
    }
    // TODO:
    /// Discards all "eligible" objects asynchronously. Objects are eligible iff the following requirements are met:
    /// 1. The object is in the context of the manager which the garbage collector was obtained from.
    /// 2. The object's type conforms to the `CCDiscardable` protocol.
    /// 3. The object's `isDiscardable` returns `true`.
    /// After cleaning has been performed, changes are not written to disk, however, the objects are deleted in the
    /// manager's context.
    ///
    /// - Returns: A promise that is resolved as soon as cleaning has been performed. The promise never fails.
    public func clean() {
        let backgroundContext = manager.createBackgroundChildContext()
        backgroundContext.async {
            self.manager.model.entities.lazy
                .filter { $0 is CCDiscardable.Type }
                .forEach { objectType in
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: objectType.entity().name!)
                    let results = CCUtility.fetch(fetchRequest, in: backgroundContext.objectContext)
                    for item in results.lazy.map({ $0 as! (NSManagedObject & CCDiscardable) }) {
                        if item.isDiscardable {
                            item.delete(in: backgroundContext)
                        }
                    }
            }
            backgroundContext.save()
        }
    }
    
}
