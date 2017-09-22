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

/// The `CCDataManager` class is used to greatly facilitate building the CoreData stack.
///
/// The manager is optimized to avoid blocking the user interface. The context that the user operates on runs on the
/// main queue, yet has a parent context that runs on a private queue. Consequently, save operations do not block the
/// user interface.
///
/// The manager supports multiple store types. When creating stores, the `NSMigratePersistentStoresAutomaticallyOption`
/// is set to true. However, a data manager may only be associated with a single model.
open class CCManager {
    
    /// The default manager to use for the application. Set this manager to your actual manager if required (preferably
    /// in the `application(didFinishLaunching:withOptions:)` method) as it is widely used in the framework: when not
    /// manually specifying a context in the concerned calls, the default value is set to this context.
    /// The default manager uses a model called `Data` and writes to a SQLite database at
    /// `<documentsDirectory>/data/appdata`.
    public static var `default` = CCManager(from: CCModel("Data"),
                                            writeTo: [CCStore(.sqlite(filename: "appdata"))],
                                            at: { $0.appendingPathComponent("data") })
    
    internal let model: CCModel
    private let persistentStores: [CCStore]
    private let persistentStoresUrl: URL
    
    private lazy var savingContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.storeCoordinator
        return context
    }()
    
    private lazy var storeCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model.objectModel)
        do {
            try FileManager.default.createDirectory(at: self.persistentStoresUrl,
                                                    withIntermediateDirectories: true, attributes: nil)
            let options = [NSMigratePersistentStoresAutomaticallyOption: true]
            for store in persistentStores {
                try store.add(to: coordinator, at: self.persistentStoresUrl, options: options)
            }
        } catch let error as NSError {
            CCUtility.postCoreDataNotification(.storeCreationDidFail, withError: error)
        }
        return coordinator
    }()
    
    /// Initializes a manager with the given properties.
    ///
    /// - Parameters:
    ///   - model:     The model that should be associated with the manager.
    ///   - stores:    The stores that are used by the manager and which are based on the given model.
    ///   - storesUrl: A closure returning the directory where to store files of persistent stores based on the
    ///                documents directory which is passed as a parameter. The default simply returns the documents
    ///                directory.
    public init(from model: CCModel, writeTo stores: [CCStore],
                at storesUrl: (URL) -> URL = { $0 }) {
        self.model = model
        self.persistentStores = stores
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.persistentStoresUrl = storesUrl(urls.last!)
    }
    
    /// The garbage collector is a utility class to delete objects managed by the current context and conforming to
    /// the `CCDiscardable` protocol.
    /// Call `clean` on the garbage collector to delete objects based on the `isDiscardable` implementation in each of
    /// the managed objects that conform to `CCDiscardable`.
    @available(iOS 10.0, *)
    public private(set) lazy var garbageCollector: CCGarbageCollector = {
        return CCGarbageCollector(manager: self)
    }()
    
    /// The main context associated with the manager. The context is associated with the main queue.
    ///
    /// - Attention: Although `context.write()` provides the same functionality as calling `write()`, do not call
    ///              `context.save()` as this operation does not save to disk but only merge changes with the saving
    ///              context.
    /// - Note: When first accessing the context, the stores are created.
    ///         Listen to the `CCErrorNotification.storeCreationDidFail` to be notified of failure to do so.
    public private(set) lazy var context: CCContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.savingContext
        return CCContext(context: managedObjectContext)
    }()
    
    /// Saves the main context and writes changes to disk if the context has changes.
    ///
    /// - Note: Listen to the `CCErrorNotification.saveDidFail` notification to be notified when the write fails.
    public func write() {
        context.write()
    }
    
    /// Returns the fetch request for the specified name in the model.
    ///
    /// - Parameters:
    ///   - name:    The name of the fetch request in the model.
    ///   - context: The context in which to use the request. The default is set to `nil` which refers to the main
    ///              context of the data manager.
    /// - Returns: The request for the specified name.
    ///
    /// - Attention: The returned request must not be modified.
    public func fetchRequest<T: NSManagedObject & CCManageable>(forName name: String) -> CCRequest<T> {
        return CCRequest(fetchRequest: model.objectModel.fetchRequestTemplate(forName: name) as! NSFetchRequest<T>)
    }
    
    /// Creates and returns a child context of the main context that runs on the main queue.
    ///
    /// - Returns: The new child context.
    public func createChildContext() -> CCContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self.context.objectContext
        return CCContext(context: context)
    }
    
    /// Creates and returns a child context of the main context that runs on a private queue.
    ///
    /// - Returns: The new background child context.
    public func createBackgroundChildContext() -> CCContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.context.objectContext
        return CCContext(context: context)
    }
    
}
