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

/// The `CCIndexable` protocol may be adopted by any managed object that require a primary key which is unique in the
/// store.
/// In case you encounter performance issues, consider adding an index to the primary key in the model.
public protocol CCIndexable: CCManageable {
    
    /// The type of the primary key. The default is set to `String`.
    associatedtype PrimaryKeyType: CCKeyType
    
    /// The key path for the primary key. The default is set to `cd_id`.
    static var primaryKeyPath: String { get }
    
} 

public extension CCIndexable {
    
    public static var primaryKeyPath: String {
        return "cd_id"
    }
    
}

extension CCIndexable where Self: CCManaged {
    
    /// Returns the object for the specified key if there exists an object with the specified key in the specified
    /// context.
    ///
    /// - Parameters:
    ///   - key:     The key for which to obtain an object for.
    ///   - context: The context in which to look for the object. The default is set to `CCManager.default.context`.
    /// - Returns: The object for the specified primary key in the given context or `nil` if there cannot be found an
    ///            object for the specified primary key.
    public static func object(forPrimaryKey key: PrimaryKeyType,
                              in context: CCContext = CCManager.default.context) -> Self? {
        return request().filterBy(predicate: NSPredicate(format: "\(primaryKeyPath) == \(Self.PrimaryKeyType.argsIdentifier)",
                                                         key)).fetch(in: context).first
    }
    
    /// Creates or fetches the object for the specified primary key in the given context.
    /// In case the object is created, the object's primary key is set right away.
    ///
    /// - Parameters:
    ///   - key:     The key for which to create or fetch an object for.
    ///   - context: The context in which to look for the object, or insert it into, respectively. The default is set
    ///              to `CCManager.default.context`.
    /// - Returns: The fetched or created object in the given context.
    @discardableResult
    public static func createIfNeeded(forPrimaryKey key: PrimaryKeyType,
                                      in context: CCContext = CCManager.default.context) -> Self {
        let object = self.object(forPrimaryKey: key, in: context) ?? Self.create(in: context)
        object.setValue(key, forKey: primaryKeyPath)
        return object
    }
    
    @discardableResult
    internal static func createIfNeeded(forPrimaryKey key: PrimaryKeyType,
                                        in context: CCContext = CCManager.default.context) -> (object: Self, didCreate: Bool) {
        if let object = self.object(forPrimaryKey: key, in: context) {
            return (object, false)
        } else {
            let object = Self.create(in: context)
            object.setValue(key, forKey: primaryKeyPath)
            return (object, true)
        }
    }
    
}
