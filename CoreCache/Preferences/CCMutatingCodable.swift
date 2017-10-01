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

public protocol CCMutatingCodable: WPCodable {
    
    static var fallbackDecoded: Self { get }
    
}

extension String: CCMutatingCodable {
    public static var fallbackDecoded: String {
        return ""
    }
}

extension Int: CCMutatingCodable {
    public static var fallbackDecoded: Int {
        return 0
    }
}

extension Int64: CCMutatingCodable {
    public static var fallbackDecoded: Int64 {
        return 0
    }
}

extension Int32: CCMutatingCodable {
    public static var fallbackDecoded: Int32 {
        return 0
    }
}

extension Int16: CCMutatingCodable {
    public static var fallbackDecoded: Int16 {
        return 0
    }
}

extension UInt: CCMutatingCodable {
    public static var fallbackDecoded: UInt {
        return 0
    }
}

extension UInt64: CCMutatingCodable {
    public static var fallbackDecoded: UInt64 {
        return 0
    }
}

extension UInt32: CCMutatingCodable {
    public static var fallbackDecoded: UInt32 {
        return 0
    }
}

extension UInt16: CCMutatingCodable {
    public static var fallbackDecoded: UInt16 {
        return 0
    }
}

extension Double: CCMutatingCodable {
    public static var fallbackDecoded: Double {
        return 0
    }
}

extension Array: CCMutatingCodable {
    public static var fallbackDecoded: Array<Element> {
        return []
    }
}

extension Dictionary: CCMutatingCodable {
    public static var fallbackDecoded: Dictionary<Key, Value> {
        return [:]
    }
}
