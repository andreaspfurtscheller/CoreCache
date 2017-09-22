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

internal struct CCUtility {
    
    internal static func postCoreDataNotification(_ notification: CCErrorNotification,
                                                 withError error: NSError) {
        #if DEBUG
            print("+++ CCManager: Error occurred ...")
            print("    \(error)")
            print("+++ ... end of error.")
        #endif
        if error.domain == NSCocoaErrorDomain {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: notification,
                                                object: nil,
                                                userInfo: ["reason": error.code])
            }
        }
    }
    
    /// Performs a fetch request in the given context and returns the results of the fetch request. The fetch operation
    /// is performed synchronously.
    ///
    /// - Parameters:
    ///   - request: The request to fetch.
    ///   - context: The context to perform the fetch request on.
    /// - Returns: An array of results or an empty array in case an error occured.
    ///
    /// - Note: Listen for the `fetchDidFail` notification to be notified when the fetch fails.
    internal static func fetch<T>(_ request: NSFetchRequest<T>, in context: NSManagedObjectContext) -> [T] {
        do {
            return try context.fetch(request)
        } catch let error as NSError {
            CCUtility.postCoreDataNotification(.fetchDidFail, withError: error)
            return []
        }
    }
    
    /// Performs the fetch for the results controller while catching any errors that may occur.
    ///
    /// - Parameter resultsController: The results controller to fetch for.
    ///
    /// - Note: Listen for the `fetchDidFail` notification to be notified when the fetch fails.
    internal static func performFetch<T>(for resultsController: NSFetchedResultsController<T>) {
        do {
            try resultsController.performFetch()
        } catch let error as NSError {
            CCUtility.postCoreDataNotification(.fetchDidFail, withError: error)
        }
    }
    
    /// Performs a count for the fetch request in the given context and returns the count. The operation is performed
    /// synchronously.
    ///
    /// - Parameters:
    ///   - request: The request to count for.
    ///   - context: The context to perform the fetch request on.
    /// - Returns: The number of objects fetched by the given fetch request or 0 in case an error occured.
    ///
    /// - Note: Listen for the `fetchDidFail` notification to be notified when the fetch fails.
    internal static func count<T>(for request: NSFetchRequest<T>, in context: NSManagedObjectContext) -> Int {
        do {
            return try context.count(for: request)
        } catch let error as NSError {
            CCUtility.postCoreDataNotification(.fetchDidFail, withError: error)
            return 0
        }
    }
    
    /// Saves the given context in case it has any changes. The operation is performed synchronously.
    ///
    /// - Parameter context: The context to save.
    ///
    /// - Note: Listen to the `saveDidFail` notification to be notified when the save fails.
    internal static func save(_ context: NSManagedObjectContext, onFinish: @escaping () -> Void = { return }) {
        context.perform {
            do {
                if context.hasChanges {
                    try context.save()
                    onFinish()
                }
            } catch let error as NSError {
                CCUtility.postCoreDataNotification(.saveDidFail, withError: error)
            }
        }
    }
    
}
