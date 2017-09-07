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

/// The `CCFilterable` protocol enables types to declare restrictions when fetching objects.
public protocol CCFilterable: CCManageable {
    
    /// An enumeration of fetch paths that it is applicable to filter by.
    /// Typically, filters are defined as enums with associated values.
    associatedtype Filter: CCFilterMapping
    
}

extension CCRequest where ResultType: CCFilterable {
    
    /// Filters the result of the request by the given 
    ///
    /// - Parameters:
    ///   - filter:   The property and condition value for filtering.
    ///   - relation: The relation to apply between the object and the object to filter by. The default is set to
    ///               `equal`.
    /// - Returns: The modified request that only includes values 
    public func filterBy(_ filter: ResultType.Filter) -> CCRequest<ResultType> {
        return filterBy(predicate: filter.predicate)
    }
    
}
