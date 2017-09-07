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

/// The `CCDiscardable` protocol may be implemented by any objects that must be continuously deleted according to some
/// predicate. The `isDiscardable` property defines whether the object may be deleted.
/// The `garbageCollector` property on the `CCManager` requires any objects that should be "collected" (deleted) to
/// implement the `CCDiscardable` protocol.
public protocol CCDiscardable: CCManageable {
    
    /// The property to determine whether the object may be "discarded" (deleted).
    /// The default implementation always returns `false`.
    var isDiscardable: Bool { get }
    
}

public extension CCDiscardable {
    
    public var isDiscardable: Bool {
        return false
    }
    
}
