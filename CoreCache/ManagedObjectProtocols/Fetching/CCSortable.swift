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

/// The `CCSortable` protocol enables `CCRequest`s to be sortable by the provided key paths.
public protocol CCSortable: CCManageable {
    
    /// An enumeration of sort paths that it is applicable to sort by.
    /// Typically, sort paths are defined as enums with raw values as `String`.
    associatedtype SortPath: CCPath
    
}

extension CCRequest where ResultType: CCSortable {
    
    /// Sorts the request by the given sort path in the given sort order.
    /// The method may be applied multiple times for sorting different properties.
    ///
    /// - Parameters:
    ///   - sortPath:  The sort path to sort the request's results by.
    ///   - sortOrder: The order in which to sort the request's results for the given sort path.
    /// - Returns: The modified request.
    public func sorted(by sortPath: ResultType.SortPath, _ sortOrder: CCSortOrder) -> CCRequest<ResultType> {
        return sortBy(keyPath: sortPath.rawValue, sortOrder: sortOrder)
    }
    
}
