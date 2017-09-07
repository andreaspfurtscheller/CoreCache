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

extension UIImage {
    
    /// Returns image data for an image that is scaled with aspect ratio such that is does not exceed the given size.
    /// If the image's height as well as width does not exceed the given max size's height and width, respectively,
    /// the image is converted into data without scaling.
    ///
    /// - Parameters:
    ///   - size:        The size that the scaled image should not exceed.
    ///   - compression: The compression to use for converting the image into data.
    /// - Returns: The data of the scaled image using the given compression.
    @available(iOS 10.0, *)
    public func resized(toMaxSize size: CGSize, withCompression compression: CUImageCompression) -> Data {
        if size.height >= self.size.height && size.width >= self.size.width {
            switch compression {
            case .png:
                return UIImagePNGRepresentation(self)!
            case .jpeg(let compression):
                return UIImageJPEGRepresentation(self, compression)!
            }
        }
        let scale = min(size.height / self.size.height, size.width / self.size.width)
        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let actions = { (context: UIGraphicsImageRendererContext) in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        switch compression {
        case .png:
            return renderer.pngData(actions: actions)
        case .jpeg(let compression):
            return renderer.jpegData(withCompressionQuality: compression, actions: actions)
        }
    }
    
}
