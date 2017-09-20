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

/// `CCRequest` provides a type-safe wrapper for `NSFetchRequest`. Its functionality is extended as the generic result
/// type conforms to certain protocols:
/// - `CCFilterable` enables adding predicates to the request.
/// - `CCSortable` enables adding sort descriptors to the request.
/// - `CCGroupable` enables grouping the results when using a `CCController`.
/// A `CCRequest` may not be constructed, but is only obtainable through the `CCManageable.request()` property.
public final class CCRequest<ResultType: NSManagedObject & CCManageable> {
    
    internal let fetchRequest: NSFetchRequest<ResultType>
    
    internal init(fetchRequest: NSFetchRequest<ResultType>) {
        self.fetchRequest = fetchRequest
    }
    
    /// Sets the maximum number of objects returned by the request as well as the offset.
    ///
    /// - Parameters:
    ///   - fetchLimit: The maximum number of objects returned by the request.
    ///   - offset:     The offset of the objects to be returned. The default is set to 0.
    /// - Returns: The modified request.
    public func with(fetchLimit: Int, offset: Int = 0) -> CCRequest<ResultType> {
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.fetchOffset = offset
        return self
    }
    
    /// Defines the fetch batch size of the request to speed up fetching in case only few of the results is actually
    /// worked with.
    ///
    /// - Parameter fetchBatchSize: The fetch batch size, where 0 is treated as infinity.
    /// - Returns: The modified request.
    public func with(fetchBatchSize: Int) -> CCRequest<ResultType> {
        fetchRequest.fetchBatchSize = fetchBatchSize
        return self
    }
    
    /// Executes the request in the given context and returns the results.
    ///
    /// - Parameter context: The context to perform the fetch request in. The default is set to
    ///                      `CCManager.default.context`.
    /// - Returns: The results of the request or an empty array if the request failed.
    ///
    /// - Note: Listen for the `CCErrorNotification.fetchDidFail` notification to be notified of failure.
    public func fetch(in context: CCContext = CCManager.default.context) -> [ResultType] {
        return CCUtility.fetch(fetchRequest, in: context.objectContext)
    }
    
    /// Executes the request in the given context and returns the number of objects that would be returned by the
    /// request.
    ///
    /// - Parameter context: The context to perform the fetch request in. The default is set to
    ///                      `CCManager.default.context`.
    /// - Returns: The number of objects that would be fetched or 0 if the fetch failed.
    ///
    /// - Note: Listen for the `CCErrorNotification.fetchDidFail` notification to be notified of failure.
    public func count(in context: CCContext = CCManager.default.context) -> Int {
        return CCUtility.count(for: fetchRequest, in: context.objectContext)
    }
    
    internal func sortBy(keyPath: String, sortOrder: CCSortOrder) -> CCRequest<ResultType> {
        fetchRequest.sortDescriptors = (fetchRequest.sortDescriptors ?? []) +
            [NSSortDescriptor(key: keyPath, ascending: sortOrder.isAscending)]
        return self
    }
    
    internal func filterBy(predicate: NSPredicate) -> CCRequest<ResultType> {
        if let oldPredicate = fetchRequest.predicate {
            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [oldPredicate, predicate])
        } else {
            fetchRequest.predicate = predicate
        }
        return self
    }
}

extension CCRequest where ResultType: CCManaged {
    
    /// Returns a `CCController` based on the current fetch request.
    ///
    /// - Parameters:
    ///   - context:   The context to fetch objects in. The default is set to `CCManager.default.context`.
    ///   - cacheName: The name of the cache that is associated with the controller to speed up loading results. The
    ///                default is set to `nil`.
    ///
    /// - Note: To specify grouping behavior, adapt the `CCGroupable` protocol in the `ResultType`.
    ///         Listen for the `CCErrorNotification.fetchDidFail` in case the results controller cannot fetch its
    ///         objects.
    public func resultsController(in context: CCContext = CCManager.default.context,
                                  cacheName: String? = nil) -> CCController<ResultType> {
        return CCController(withRequest: self, in: context.objectContext, cacheName: cacheName)
    }
    
}
