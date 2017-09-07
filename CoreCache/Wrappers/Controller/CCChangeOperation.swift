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

import Foundation

/// `CCObjectChangeOperation` provides an overview over possible change operations in a `CCController`'s objects.
///
/// - insertion(at: IndexPath):             Inserted an object at the given index path.
/// - deletion(at: IndexPath):              Deleted the object at the given index path.
/// - move(from: IndexPath, to: IndexPath): Moved the object at the source index path to the destination index path.
/// - update(at: IndexPath:                 Updated the object at the given index path.
public enum CCObjectChangeOperation {
    
    case insertion(at: IndexPath)
    case deletion(at: IndexPath)
    case move(from: IndexPath, to: IndexPath)
    case update(at: IndexPath)
    
}

/// `CCSectionChangeOperation` provides an overview over possible change operation in a `CCController`'s sections.
///
/// - insertion(at: Int): Inserted a section at the given index.
/// - deletion(at: Int):  Deleted the section at the given index.
public enum CCSectionChangeOperation {
    
    case insertion(at: Int)
    case deletion(at: Int)
    
}
