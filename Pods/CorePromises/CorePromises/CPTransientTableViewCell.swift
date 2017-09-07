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

/// A table view cell subclass that provides a transient queue (operating on the main thread) on which all asynchronous
/// operations modifying the table view cell should be performed (reason: table view cells might be reused).
open class CPTransientTableViewCell: UITableViewCell {
    
    /// The transient queue on which to perform all asynchronous modifications to the the cell.
    public private(set) var transientQueue = CPTransientQueue(.main)
    
    /// The method that is executed when a table view cell is about to be reused.
    /// The current transient queue is invalidated and a new one is created.
    override open func prepareForReuse() {
        super.prepareForReuse()
        
        transientQueue.invalidate()
        transientQueue = CPTransientQueue(.main)
    }
    
}
