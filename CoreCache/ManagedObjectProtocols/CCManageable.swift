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

/// The `CCManageable` protocol is the fundamental protocol of the CoreCache framework to facilitate using CoreData.
/// Instead of adopting this protocol in a simple `NSManagedObject` subclass, inherit from `CCManaged` which also
/// provides a useful default implementation of the `mainContext` computed property.
public protocol CCManageable {
    
    /// The context in which the object is primarily used.
    static var mainContext: CCContext { get }
    
}

extension CCManageable where Self: NSManagedObject {
    
    /// Creates an instance of self and inserts it into the given context.
    ///
    /// - Parameter context: The context to insert the object into. The default is set to `CCManager.default.context`.
    /// - Returns: The created object.
    @discardableResult
    public static func create(in context: CCContext = CCManager.default.context) -> Self {
        return Self(entity: NSEntityDescription.entity(forEntityName: String(describing: Self.self),
                                                       in: context.objectContext)!,
                    insertInto: context.objectContext)
    }
    
    internal static func defaultFetchRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest<Self>(entityName: String(describing: Self.self))
    }
    
    /// Returns a request for all instances of `Self`.
    ///
    /// - Returns: The request for all instances.
    public static func request() -> CCRequest<Self> {
        return CCRequest(fetchRequest: defaultFetchRequest())
    }
    
    /// Carries the object over to the specified context and returns it as instance in the given context.
    ///
    /// - Parameter context: The context to carry the instance over to.
    /// - Returns: The instance in the specified context.
    public func `in`(_ context: CCContext) -> Self {
        return context.objectContext.object(with: objectID) as! Self
    }
    
    /// Deletes the object in the given context.
    ///
    /// - Parameter context: The context to delete the object in. The default is set to `CCManager.default.context`.
    public func delete(in context: CCContext = CCManager.default.context) {
        context.objectContext.delete(self)
    }
    
}
