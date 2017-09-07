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

public protocol CCCachable: CCIndexable {
    
    /// Updates the given object with the values of the given container.
    /// The primary key must not be modified in this method.
    /// The default implementation does nothing
    ///
    /// - Parameters:
    ///   - container: The container to use for mapping the data.
    ///   - object:    The object to be modified by the container.
    static func map<Container: CCContainer>(from container: Container, to object: Self)
                    where Container.PrimaryKeyType == Self.PrimaryKeyType
    
}

public extension CCCachable {
    
    static func map<Container: CCContainer>(from container: Container, to object: Self)
        where Container.PrimaryKeyType == Self.PrimaryKeyType {
            // do nothing
    }
    
}

public extension CCCachable where Self: CCManaged {
    
    @discardableResult
    public static func scratch<Container: CCContainer>(with container: Container,
                                                       in context: CCContext = CCManager.default.context) -> Self
        where Container.PrimaryKeyType == Self.PrimaryKeyType {
            let object = Self.createIfNeeded(forPrimaryKey: container.primaryKey)
            map(from: container, to: object)
            return object
    }
    
}
