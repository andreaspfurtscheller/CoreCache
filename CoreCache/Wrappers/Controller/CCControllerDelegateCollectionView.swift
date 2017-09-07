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

/// A delegate implementation for the `CCControllerDelegate` used for table views.
/// A `CCControllerDelegateCollectionView` is always associated with a single collection view and a delegate for
/// configuring a collection view cell.
open class CCControllerDelegateCollectionView: CCControllerDelegate {
    
    private var collectionView: UICollectionView
    private unowned let delegate: CCControllerDelegateCollectionViewDelegate
    
    /// Initializes a new `CCControllerCollectionView` with the given properties.
    ///
    /// - Parameters:
    ///   - managing: The collection view to be managed.
    ///   - delegate: The delegate to configure a cell at a given index path.
    init(managing: UICollectionView, delegate: CCControllerDelegateCollectionViewDelegate) {
        self.collectionView = managing
        self.delegate = delegate
    }
    
    public func controllerWillChangeContent<ResultType>(_ controller: CCController<ResultType>) {
        // do nothing
    }
    
    public func controller<ResultType>(_ controller: CCController<ResultType>,
                                       didChangeWithOperation changeOperation: CCObjectChangeOperation) {
        switch changeOperation {
        case .deletion(at: let indexPath):
            collectionView.deleteItems(at: [indexPath])
        case .insertion(at: let indexPath):
            collectionView.insertItems(at: [indexPath])
        case .move(from: let sourceIndexPath, to: let destinationIndexPath):
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        case .update(at: let indexPath):
            if let cell = collectionView.cellForItem(at: indexPath) {
                delegate.configure(cell, at: indexPath)
            }
        }
    }
    
    public func controllerDidChangeContent<ResultType>(_ controller: CCController<ResultType>) {
        // do nothing
    }
    
    public func controller<ResultType>(_ controller: CCController<ResultType>,
                                       didChangeSectionWithOperation changeOperation: CCSectionChangeOperation) {
        switch changeOperation {
        case .deletion(at: let index):
            collectionView.deleteSections([index])
        case .insertion(at: let index):
            collectionView.insertSections([index])
        }
    }
    
}
