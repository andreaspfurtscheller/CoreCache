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

/// The `CCModel` struct is a wrapper for a `NSManagedObjectModel`. Publicly, the wrapper does only support
/// initialization with the name of the model.
public struct CCModel {
    
    internal let objectModel: NSManagedObjectModel
    
    /// Initializes a model with the specified name in the specified bundle.
    ///
    /// - Parameters:
    ///   - name:   The name of the model without any file extensions.
    ///   - bundle: The bundle in which the model is located. The default is set to the main bundle.
    ///
    /// - Attention: The initializer terminates the program if the model cannot be found.
    public init(_ name: String, bundle: Bundle = .main) {
        self.objectModel = NSManagedObjectModel(contentsOf: bundle.url(forResource: name,
                                                                       withExtension: "momd")!)!
    }
    
    internal var entities: [NSManagedObject.Type] {
        return objectModel.entities.lazy
            .map { $0.managedObjectClassName }
            .map { NSClassFromString($0) }
            .map { $0 as! NSManagedObject.Type }
    }
    
}
