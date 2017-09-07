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

import UIKit
import CoreData

/// The protocol which all delegates for the `CCController` have to implement.
///
/// - Note: Consider subclassing `CCControllerTableView` or `CCControllerCollectionView` instead of directly adopting
///         the protocol.
public protocol CCControllerDelegate {
    
    /// Non-optional call when the objects of the controller are about to change.
    ///
    /// - Parameter controller: The controller whose objects have changed.
    func controllerWillChangeContent<ResultType>(_ controller: CCController<ResultType>)
    
    /// Non-optional call when the controller's displayed results changed.
    ///
    /// - Parameters:
    ///   - controller:      The controller whose objects changed.
    ///   - changeOperation: The operation that caused the change in the objects.
    func controller<ResultType>(_ controller: CCController<ResultType>,
                                didChangeWithOperation changeOperation: CCObjectChangeOperation)
    
    /// Non-optional call when the objects of the controller have finished changing.
    ///
    /// - Parameter controller: The controller whose objects have finished changing.
    func controllerDidChangeContent<ResultType>(_ controller: CCController<ResultType>)
    
    /// Optional call to obtain the section index title for the specified section.
    /// The default implementation always returns `nil`.
    ///
    /// - Parameters:
    ///   - controller:  The controller which to obtain the section index title for.
    ///   - sectionName: The name of the section to obtain the section index title for.
    /// - Returns: The section index title.
    func controller<ResultType>(_ controller: CCController<ResultType>,
                                sectionIndexTitleForSectionName sectionName: String) -> String?
    
    /// Optional call when a section changed.
    /// The default implementation does nothing.
    ///
    /// - Parameters:
    ///   - controller:      The controller whose sections changed.
    ///   - changeOperation: The operation that caused the change in the sections.
    func controller<ResultType>(_ controller: CCController<ResultType>,
                                didChangeSectionWithOperation changeOperation: CCSectionChangeOperation)
    
}

public extension CCControllerDelegate {
    
    public func controller<ResultType>(_ controller: CCController<ResultType>,
                                       sectionIndexTitleForSectionName sectionName: String) -> String? {
        return nil
    }
    
    public func controller<ResultType>(_ controller: CCController<ResultType>,
                                       didChangeSectionWithOperation changeOperation: CCSectionChangeOperation) {
        // do nothing
    }
    
}
