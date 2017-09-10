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
import CoreData

@objc(CCImage)
internal final class CCImage: CCManaged {
    
    var data: Data {
        return cd_image as Data
    }
    
    var size: Int {
        return cd_image.length
    }
    
    @NSManaged
    private var cd_image: NSData
    @NSManaged
    private var cd_lastAccessed: NSDate
    @NSManaged
    private var cd_url: String
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        cd_lastAccessed = Date() as NSDate
    }
    
    override func awakeFromFetch() {
        super.awakeFromFetch()
        cd_lastAccessed = Date() as NSDate
    }
    
}

extension CCImage: CCSortable {
    
    internal enum SortPath: String, CCPath {
        case lastAccessed = "cd_lastAccessed"
    }
    
}

extension CCImage: CCIndexable {
    
    typealias PrimaryKeyType = String
    
    static var primaryKeyPath: String {
        return "cd_url"
    }
    
}

extension CCImage: CCUpdateable {
    
    enum Updater: CCUpdateMapping {
        case imageData(Data)
    }
    
    static func update(_ property: CCImage.Updater, on object: CCImage) {
        switch property {
        case .imageData(let data): object.cd_image = data as NSData
        }
    }
    
}
