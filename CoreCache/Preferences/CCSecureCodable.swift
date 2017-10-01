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

import SwiftKeychainWrapper

public protocol CCSecureCodable {
    
    init(securelyFromKey key: String)
    func storeSecurely(forKey key: String)
    
}

extension Int: CCSecureCodable {
    public init(securelyFromKey key: String) {
        self = KeychainWrapper.standard.integer(forKey: key) ?? 0
    }
    
    public func storeSecurely(forKey key: String) {
        KeychainWrapper.standard.set(self, forKey: key)
    }
}

extension Double: CCSecureCodable {
    public init(securelyFromKey key: String) {
        self = KeychainWrapper.standard.double(forKey: key) ?? 0
    }
    
    public func storeSecurely(forKey key: String) {
        KeychainWrapper.standard.set(self, forKey: key)
    }
}

extension Bool: CCSecureCodable {
    public init(securelyFromKey key: String) {
        self = KeychainWrapper.standard.bool(forKey: key) ?? false
    }
    
    public func storeSecurely(forKey key: String) {
        KeychainWrapper.standard.set(self, forKey: key)
    }
}

extension Data: CCSecureCodable {
    public init(securelyFromKey key: String) {
        self = KeychainWrapper.standard.data(forKey: key) ?? Data()
    }
    
    public func storeSecurely(forKey key: String) {
        KeychainWrapper.standard.set(self, forKey: key)
    }
}

extension Float: CCSecureCodable {
    public init(securelyFromKey key: String) {
        self = KeychainWrapper.standard.float(forKey: key) ?? 0
    }
    
    public func storeSecurely(forKey key: String) {
        KeychainWrapper.standard.set(self, forKey: key)
    }
}

extension String: CCSecureCodable {
    public init(securelyFromKey key: String) {
        self = KeychainWrapper.standard.string(forKey: key) ?? ""
    }
    
    public func storeSecurely(forKey key: String) {
        KeychainWrapper.standard.set(self, forKey: key)
    }
}
