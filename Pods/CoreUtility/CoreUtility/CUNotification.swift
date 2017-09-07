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

/// `CUNotification` is a protocol that may be implemented by an arbitrary enum type to be easily posted
/// to the `NotificationCenter`.
public protocol CUNotification {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: CUNotification {
    public var name: Notification.Name {
        return Notification.Name(self.rawValue)
    }
}

public extension NotificationCenter {
    
    /// A wrapper for `Foundation`'s `post` method for easier use with `CUNotification`.
    public func post(name notification: CUNotification,
                     object: Any? = nil,
                     userInfo: [AnyHashable: Any]? = nil) {
        self.post(name: notification.name,
                  object: object,
                  userInfo: userInfo)
    }
    
    /// A wrapper for `Foundation`'s `addObserver` method for easier use with `CUNotification`.
    public func addObserver(_ observer: Any, selector: Selector, name: CUNotification, object: Any?) {
        self.addObserver(observer, selector: selector, name: name.name, object: object)
    }
    
}
