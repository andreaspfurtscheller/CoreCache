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
import CoreUtility

internal class CCObserver<Element: NSManagedObject & CCManageable> {
    
    private unowned let context: CCContext
    
    init(context: CCContext) {
        self.context = context
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: context.objectContext)
    }
    
    func handleObserverChange(_ change: CCObserverContextChanges<Element>) {
        context.observers.removeDeallocateds { $0.observer }
    }
    
    @objc private func handleNotification(_ notification: Notification) {
        if let updates = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            let objects = updates.filter { $0 is Element }
            handleObserverChange(.update(objects as! Set<Element>))
        }
        if let insertions = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            let objects = insertions.filter { $0 is Element }
            handleObserverChange(.insertion(objects as! Set<Element>))
        }
        if let deletions = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            let objects = deletions.filter { $0 is Element }
            handleObserverChange(.insertion(objects as! Set<Element>))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

internal class CCRequestObserver<Element: NSManagedObject & CCManageable>: CCObserver<Element> {
    
    private let requests: [CCRequest<Element>]
    private let handler: (CCObserverChange<Element>) -> Void
    
    init(requests: [CCRequest<Element>], context: CCContext, handler: @escaping (CCObserverChange<Element>) -> Void) {
        self.requests = requests
        self.handler = handler
        super.init(context: context)
    }
    
    override func handleObserverChange(_ change: CCObserverContextChanges<Element>) {
        super.handleObserverChange(change)
        switch change {
        case .update(let elements):
            for item in elements where requests.any(fulfillingPredicate: { $0.fetchRequest.predicate?.evaluate(with: item) ?? true }) {
                handler(.update(item))
            }
        case .insertion(let elements):
            for item in elements where requests.any(fulfillingPredicate: { $0.fetchRequest.predicate?.evaluate(with: item) ?? true }) {
                handler(.insertion(item))
            }
        case .deletion(let elements):
            for item in elements where requests.any(fulfillingPredicate: { $0.fetchRequest.predicate?.evaluate(with: item) ?? true }) {
                handler(.deletion(item))
            }
        }
    }
}

internal class CCElementObserver<Element: NSManagedObject & CCManageable>: CCObserver<Element> {
    
    private let elements: Set<Element>
    private let handler: (CCObserverChange<Element>) -> Void
    
    init(elements: [Element], context: CCContext, handler: @escaping (CCObserverChange<Element>) -> Void) {
        self.elements = Set(elements)
        self.handler = handler
        super.init(context: context)
    }
    
    override func handleObserverChange(_ change: CCObserverContextChanges<Element>) {
        super.handleObserverChange(change)
        switch change {
        case .update(let elements):
            for item in elements where elements.contains(item) {
                handler(.update(item))
            }
        case .insertion(_):
            break
        case .deletion(let elements):
            for item in elements where elements.contains(item) {
                handler(.deletion(item))
            }
        }
    }
}
