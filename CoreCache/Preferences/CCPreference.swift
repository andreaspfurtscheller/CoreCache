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

import WebParsing

public struct CCFlagPreference {
    
    private let key: String
    private unowned let preferences: CCPreferences
    
    public init(_ key: String, preferences: CCPreferences = CCPreferences.default) {
        self.key = key
        self.preferences = preferences
    }
    
    public var value: Bool {
        let result = !(preferences.preferences[key].boolValue ?? false)
        if result {
            preferences.preferences[key] = true
            preferences.write()
        }
        return result
    }
}

public struct CCMutatingPreference<T: CCMutatingCodable> {
    
    private let key: String
    private unowned let preferences: CCPreferences
    
    public init(_ key: String, preferences: CCPreferences = CCPreferences.default) {
        self.key = key
        self.preferences = preferences
    }
    
    public var value: T {
        return (try? WPJsonDecoder.decode(preferences.preferences[key])) ?? T.fallbackDecoded
    }
    
    public func set(_ value: T) {
        preferences.preferences[key] = try! WPJsonEncoder.encode(value)
        preferences.write()
    }
    
}

public struct CCSecurePreference<T: CCSecureCodable> {
    
    private let key: String
    
    public init(_ key: String) {
        self.key = key
    }
    
    public var value: T {
        return T(securelyFromKey: key)
    }
    
    public func set(_ value: T) {
        value.storeSecurely(forKey: key)
    }
}
