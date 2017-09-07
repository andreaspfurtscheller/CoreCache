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

/// The `CCGroupable` protocol enables `CCRequest`s to be groupable by the provided key paths.
public protocol CCGroupable: CCManageable {
    
    /// An enumeration of sections paths that it is applicable to group by.
    /// Typically, section paths are defined as enums with raw values as `String`.
    associatedtype SectionPath: CCPath
    
}

extension CCRequest where ResultType: CCManaged & CCGroupable {
    
    /// Returns a `CCController` based on the current fetch request.
    ///
    /// - Parameters:
    ///   - context:   The context to fetch objects in. The default is set to `CCManager.default.context`.
    ///   - section:   The section path to group the results by. Keep in my that the last sorting of the request
    ///                has to be performed with the same identifier as the given section path.
    ///   - cacheName: The name of the cache that is associated with the controller to speed up loading results. The
    ///                default is set to `nil`.
    ///
    /// - Note: Listen for the `CCErrorNotification.fetchDidFail` in case the results controller cannot fetch its
    ///         objects.
    public func resultsController(in context: CCContext = CCManager.default.context,
                                  groupedBy section: ResultType.SectionPath,
                                  cacheName: String? = nil) -> CCController<ResultType> {
        return CCController(withRequest: self, in: context.objectContext,
                            section: section.rawValue, cacheName: cacheName)
    }
    
}
