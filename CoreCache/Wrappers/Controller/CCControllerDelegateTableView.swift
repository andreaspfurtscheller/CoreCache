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
/// A `CCControllerDelegateTableView` is always associated with a single table view and a delegate for configuring
/// a table view cell.
open class CCControllerDelegateTableView: CCControllerDelegate {
    
    private var tableView: UITableView
    private unowned let delegate: CCControllerDelegateTableViewDelegate
    
    /// Initializes a new `CCControllerTableView` with the given properties.
    /// 
    /// - Parameters:
    ///   - managing: The table view to be managed.
    ///   - delegate: The delegate to configure a cell at a given index path.
    public init(managing: UITableView, delegate: CCControllerDelegateTableViewDelegate) {
        self.tableView = managing
        self.delegate = delegate
    }
    
    public func controllerWillChangeContent<ResultType>(_ controller: CCController<ResultType>) {
        tableView.beginUpdates()
    }
    
    public func controller<ResultType>(_ controller: CCController<ResultType>,
                                       didChangeWithOperation changeOperation: CCObjectChangeOperation) {
        switch changeOperation {
        case .deletion(at: let indexPath):
            tableView.deleteRows(at: [indexPath], with: deletionAnimation)
        case .insertion(at: let indexPath):
            tableView.insertRows(at: [indexPath], with: insertionAnimation)
        case .move(from: let sourceIndexPath, to: let destinationIndexPath):
            tableView.deleteRows(at: [sourceIndexPath], with: deletionAnimation)
            tableView.insertRows(at: [destinationIndexPath], with: insertionAnimation)
        case .update(at: let indexPath):
            if let cell = tableView.cellForRow(at: indexPath) {
                delegate.configure(cell, at: indexPath)
            }
        }
    }
    
    public func controllerDidChangeContent<ResultType>(_ controller: CCController<ResultType>) {
        tableView.endUpdates()
    }
    
    public func controller<ResultType>(_ controller: CCController<ResultType>,
                                       didChangeSectionWithOperation changeOperation: CCSectionChangeOperation) {
        switch changeOperation {
        case .deletion(at: let index):
            tableView.deleteSections([index], with: sectionDeletionAnimation)
        case .insertion(at: let index):
            tableView.insertSections([index], with: sectionInsertionAnimation)
        }
    }
    
    /// The animation used when deleting rows in the table view. The default is set to `automatic`.
    open var deletionAnimation: UITableViewRowAnimation {
        return .automatic
    }
    
    /// The animation used when inserting rows in the table view. The default is set to `automatic`.
    open var insertionAnimation: UITableViewRowAnimation {
        return .automatic
    }
    
    /// The animation used when deleting sections in the table view. The default is set to `automatic`.
    open var sectionDeletionAnimation: UITableViewRowAnimation {
        return .automatic
    }
    
    /// The animation used when inserting sections in the table view. The default is set to `automatic`.
    open var sectionInsertionAnimation: UITableViewRowAnimation {
        return .automatic
    }
    
}

