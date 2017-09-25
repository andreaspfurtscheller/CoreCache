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

/// The `CCController` wraps the `NSFetchedResultsController` and provides key accessors for using it.
/// Use the `CCController` whenever displaying stored data.
/// The controller can only be obtained by calling `resultsController` on a `CCRequest`.
///
/// - Note: The `CCController` does not provide a `performFetch` method as the fetching is already performed when
///         obtaining the controller.
public final class CCController<ResultType: CCManaged> {
    
    /// The delegate of the controller.
    ///
    /// - Attention: The delegate holds a strong reference to the provided object. Do not implement the
    ///              `CCControllerDelegate`.
    /// - Note: For table views and collection views, use the `CCControllerTableView` and the
    ///         `CCControllerCollectionView`, respectively. Both of them enable subclassing for configuration.
    public var delegate: CCControllerDelegate? {
        get {
            return controllerDelegate?.delegate
        } set(newDelegate) {
            if let delegate = newDelegate {
                controllerDelegate = CCFetchedResultsControllerDelegate(delegate: delegate, parent: self)
            } else {
                controllerDelegate = nil
            }
            resultsController.delegate = controllerDelegate
        }
    }
    
    private var controllerDelegate: CCFetchedResultsControllerDelegate<ResultType>?
    
    internal let resultsController: NSFetchedResultsController<ResultType>
    
    internal init(withRequest request: CCRequest<ResultType>, in context: NSManagedObjectContext,
                  section: String? = nil, cacheName: String? = nil) {
        resultsController = NSFetchedResultsController(fetchRequest: request.fetchRequest,
                                                       managedObjectContext: context,
                                                       sectionNameKeyPath: section,
                                                       cacheName: cacheName)
        CCUtility.performFetch(for: resultsController)
    }
    
    /// The number of sections of the controller.
    ///
    /// - Returns: The number of sections.
    public func numberOfSections() -> Int {
        return resultsController.sections?.count ?? 0
    }
    
    /// The number of objects in the specified section.
    ///
    /// - Parameter section: The section to obtain the number of objects for. If `section >= numberOfSections`, the
    ///                      program is terminated.
    /// - Returns: The number of objects in the section.
    public func numberOfObjects(inSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    /// All objects that are currently fetched by the controller.
    ///
    /// - Returns: The fetched objects.
    public func objects() -> [ResultType] {
        return resultsController.fetchedObjects ?? []
    }
    
    /// The objects in the specified section.
    ///
    /// - Parameter section: The section to obtain the objects for. If `section >= numberOfSections`, the program is
    ///                      terminated.
    /// - Returns: The number of objects in the section.
    public func objects(inSection section: Int) -> [ResultType] {
        return (resultsController.sections ?? []) as! [ResultType]
    }
    
    /// The object at the specified index path.
    ///
    /// - Parameter indexPath: The index path to obtain the object for. If there exists no object for the specified
    ///                        index path, the program is terminated.
    /// - Returns: The object at the index path.
    public func object(at indexPath: IndexPath) -> ResultType {
        return resultsController.object(at: indexPath)
    }
    
}

fileprivate final class CCFetchedResultsControllerDelegate<ResultType: CCManaged>: NSObject, NSFetchedResultsControllerDelegate {
    
    fileprivate let delegate: CCControllerDelegate
    private unowned let parent: CCController<ResultType>
    
    init(delegate: CCControllerDelegate, parent: CCController<ResultType>) {
        self.delegate = delegate
        self.parent = parent
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate.controllerWillChangeContent(parent)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                    at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            delegate.controller(parent, didChangeWithOperation: .insertion(at: newIndexPath!))
        case .delete:
            delegate.controller(parent, didChangeWithOperation: .deletion(at: indexPath!))
        case .move:
            delegate.controller(parent, didChangeWithOperation: .move(from: indexPath!, to: newIndexPath!))
        case .update:
            delegate.controller(parent, didChangeWithOperation: .update(at: indexPath!))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate.controllerDidChangeContent(parent)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    sectionIndexTitleForSectionName sectionName: String) -> String? {
        return delegate.controller(parent, sectionIndexTitleForSectionName: sectionName)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            delegate.controller(parent, didChangeSectionWithOperation: .insertion(at: sectionIndex))
        case .delete:
            delegate.controller(parent, didChangeSectionWithOperation: .deletion(at: sectionIndex))
        default:
            break
        }
    }
    
}
