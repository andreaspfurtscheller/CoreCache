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
import CoreLocation
import WebParsing
import SwiftKeychainWrapper

open class CCPreferences {
    
    public static var `default`: CCPreferences! = nil
    
    private let filename: String
    
    private lazy var hasChanges = false
    
    internal lazy var preferences: WPJson = {
        #if DEBUG
            print(">>> PIPreferences: File path...")
            print("    " + self.preferencesUrl.path)
            print("<<< ... end of file path.")
        #endif
        if !FileManager.default.fileExists(atPath: self.preferencesUrl.path) {
            return WPJson([:])
        }
        return WPJson(readingFrom: self.preferencesUrl)
    }()
    
    private var preferencesUrl: URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let directory = url.appendingPathComponent("corecache")
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        return directory.appendingPathComponent("\(filename).json")
    }
    
    public init(filename: String) {
        self.filename = filename
    }
    
    internal func write() {
        try? preferences.data()?.write(to: preferencesUrl)
        hasChanges = false
    }
    
}
