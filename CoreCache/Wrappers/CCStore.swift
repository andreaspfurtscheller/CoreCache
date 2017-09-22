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

/// `CCStore` provides an interface for stores that may be associated with a `CCManager`.
/// It provides the store types available on iOS. As `CCModel`, it is only used as wrapper and does not provide any
/// functionality after being initialized.
public struct CCStore {
    
    /// The store types available on iOS. Provided filenames do not need file extensions (e.g. `.sqlite`).
    ///
    /// - sqlite(filename: String): An SQLite database stored at the specified filename.
    /// - binary(filename: String): A binary file stored at the specified filename.
    /// - inMemory:                 An in-memory store.
    public enum StoreType {
        case sqlite(filename: String)
        case binary(filename: String)
        case inMemory
    }
    
    private let type: StoreType
    private let configuration: String?
    
    /// Initializes a `CCStore` with the specified type and configuration.
    ///
    /// - Parameters:
    ///   - type:          The type of the store, possibly associated with a filename.
    ///   - configuration: The configuration in the model to be used. The default is set to `nil`.
    public init(_ type: StoreType, configuration: String? = nil) {
        self.type = type
        self.configuration = configuration
    }
    
    internal func add(to coordinator: NSPersistentStoreCoordinator, at directory: URL,
                      options: [AnyHashable: Any]?) throws {
        switch self.type {
        case .sqlite(filename: let filename):
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: self.configuration,
                                               at: directory.appendingPathComponent(filename + ".sqlite"),
                                               options: options)
        case .binary(filename: let filename):
            try coordinator.addPersistentStore(ofType: NSBinaryStoreType, configurationName: self.configuration,
                                               at: directory.appendingPathComponent(filename + ".blob"),
                                               options: options)
        case .inMemory:
            try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: self.configuration,
                                               at: nil, options: options)
        }
    }

}
