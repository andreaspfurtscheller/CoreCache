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

/// The `CCObserveable` protocol provides a possibility of observing object changes. To make use of the functionality,
/// the managed object needs to inherit from `CCManagedObserving`.
public protocol CCObserveable: CCManageable {
    
}

/// The `CCManagedObserving` class enables a managed object to be observeable.
open class CCManagedObserving: CCManaged {
    
    fileprivate lazy var observerCallbacks = [AnyHashable: (Any) -> Void]()
    fileprivate lazy var deletionObserverCallbacks = [AnyHashable: () -> Void]()
    
    /// Calls the super implementation of `awakeFromFetch` and adds observers.
    open override func awakeFromFetch() {
        super.awakeFromFetch()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceive(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: nil)
    }
    
    /// Calls the super implementation of `awakeFromInsert` and adds obbservers.
    open override func awakeFromInsert() {
        super.awakeFromInsert()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceive(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: nil)
    }
    
    @objc
    private func didReceive(notification: Notification) {
        if let updates = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.contains(self) {
            observerCallbacks.values.forEach { $0(self) }
        }
        if let deletions = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletions.contains(self) {
            deletionObserverCallbacks.values.forEach { $0() }
        }
    }
    
    /// Calls the super implementation of `willTurnIntoFault` and removes observers.
    open override func willTurnIntoFault() {
        super.willTurnIntoFault()
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension CCObserveable where Self: CCManagedObserving {
    
    /// Observes the managed object with the given observer. The callback is executed every time the managed object
    /// changes. There may only be one callback per observer.
    ///
    /// - Parameters:
    ///   - observer: The object to observe changes to the managed object.
    ///   - callback: The task to execute when the managed object changed.
    public func observeUpdate(by observer: AnyHashable, _ callback: @escaping (Self) -> Void) {
        observerCallbacks[observer] = { value in callback(value as! Self) }
    }
    
    /// Observes the managed object with the given observer. The callback is executed as the managed object is deleted.
    /// The may only be one callback per observer.
    ///
    /// - Parameters:
    ///   - observer: The object to observe a deletion of the managed object.
    ///   - callback: The task to execute when the managed object is deleted.
    public func observeDeletion(by observer: AnyHashable, _ callback: @escaping () -> Void) {
        deletionObserverCallbacks[observer] = callback
    }
    
    /// Removes the callback associated with the given observer when the object is changed.
    ///
    /// - Parameter observer: The observer to remove the callback for.
    public func unobserveUpdate(by observer: AnyHashable) {
        observerCallbacks[observer] = nil
    }
    
    /// Removes the callback associated with the given observer when the object is deleted.
    ///
    /// - Parameter observer: The observer to remove the callback for.
    public func unobserveDeletion(by observer: AnyHashable) {
        deletionObserverCallbacks[observer] = nil
    }
    
    /// Removes the callback associated with the given observer when the object is either changed or deleted.
    ///
    /// - Parameter observer: The observer to remove callbacks for.
    public func unobserve(by observer: AnyHashable) {
        unobserveUpdate(by: observer)
        unobserveDeletion(by: observer)
    }
    
    /// Removes all observers and callbacks for when the managed object is changed.
    public func unobserveUpdates() {
        observerCallbacks.removeAll()
    }
    
    /// Removes all observers and callbacks for when the managed object is deleted.
    public func unobserveDeletions() {
        deletionObserverCallbacks.removeAll()
    }
    
    /// Removes all observers and callbacks.
    public func unobserve() {
        unobserveUpdates()
        unobserveDeletions()
    }
    
}
