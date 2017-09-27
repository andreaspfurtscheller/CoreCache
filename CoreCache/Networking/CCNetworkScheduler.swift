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

import CorePromises
import Alamofire
import WebParsing

@available(iOS 10.0, *)
open class CCNetworkScheduler {
    
    #if DEBUG
        public var shouldPrintRequests = true
        public var shouldPrintResponses = true
        public var shouldPrintBandwidth = false
        public var shouldPrintEstimatedTraffic = false
    #endif
    
    public enum RequestPriority {
        case low
        case normal
        case high
        case required
        
        internal var value: Int {
            switch self {
            case .low: return 100
            case .normal: return 500
            case .high: return 1000
            case .required: return 5000
            }
        }
    }
    
    private struct StalledRequest: Hashable {
        
        private static var ids = 0
        
        let request: DataRequest
        let priority: Int
        let dateAdded: Date
        let identifier: String
        #if DEBUG
            private let id: Int = {
                StalledRequest.ids += 1
                return ids - 1
            }()
            
            var uniqueIdentifier: String {
                return identifier + "_\(id)"
            }
        #endif
        
        init(_ request: DataRequest, priority: RequestPriority, identifier: String) {
            self.request = request
            self.priority = priority.value
            self.dateAdded = Date()
            self.identifier = identifier
        }
        
        var hashValue: Int {
            return dateAdded.hashValue
        }
        
        static func ==(lhs: StalledRequest, rhs: StalledRequest) -> Bool {
            return lhs.dateAdded == rhs.dateAdded
        }
        
    }
    
    private typealias ActiveRequest = String
    
    public static private(set) var shared = CCNetworkScheduler()
    
    public var httpHeaders: CCNetworkHeaders = SessionManager.defaultHTTPHeaders
    
    private let sessionManager: SessionManager
    private let lockingQueue = DispatchQueue(label: "", qos: .userInitiated)
    
    private lazy var statusInformation: WPJson = {
        if !FileManager.default.fileExists(atPath: self.statusInformationUrl.path) {
            return WPJson([:])
        }
        return WPJson(readingFrom: self.statusInformationUrl)
    }()
    
    private var statusInformationUrl: URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let directory = url.appendingPathComponent("cccache").appendingPathComponent("ccnetworkscheduler")
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        return directory.appendingPathComponent("info.json")
    }
    
    private var stalledRequests = Set<StalledRequest>()
    private var activeRequests = Set<ActiveRequest>()
    private var currentBandwidth = 1.0 // byte/s
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = httpHeaders
        configuration.timeoutIntervalForResource = 120
        configuration.timeoutIntervalForRequest = 30
        sessionManager = SessionManager(configuration: configuration)
        sessionManager.startRequestsImmediately = false
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            DispatchQueue.global(qos: .background).async {
                try? self.statusInformation.data()?.write(to: self.statusInformationUrl)
            }
        }
    }
    
    @discardableResult
    public func request<Operation: CCNetworkOperation>(_ operation: Operation, priority: RequestPriority = .required,
                                                       progressHandler: @escaping (Double) -> Void = { _ in return }) -> CPPromise<Operation.ResultType> {
        guard let request = try? self.createRequest(from: operation) else {
            return CPPromise(error: CCNetworkError.invalidRequestContent)
        }
        switch operation.requestContent {
        case .data(_):
            (request as! UploadRequest).uploadProgress { progress in
                progressHandler(progress.fractionCompleted)
            }
        case .parameters(data: _, encoding: _):
            request.downloadProgress { progress in
                progressHandler(progress.fractionCompleted)
            }
        }
        
        let stalledRequest = StalledRequest(request, priority: priority, identifier: String(describing: Operation.self))
        
        self.lockingQueue.async {
            self.stalledRequests.insert(stalledRequest)
            self.performRequests()
        }
        let dataPromise: CPPromise<Data> = request.responseData { response in
            #if DEBUG
                switch response.result {
                case .success(let data):
                    if self.shouldPrintResponses {
                        print(">>> CCNetworkManager: Request \(stalledRequest.uniqueIdentifier) did finish...")
                        if let statusCode = response.response?.statusCode {
                            print("    Status code: \(statusCode)")
                        } else {
                            print("    Status code: <undefined>")
                        }
                        let jsonString = WPJson(reading: data).description(forOffset: "\t\t", prettyPrinted: true,
                                                                           truncatesStrings: true)
                        print("    JSON Response:\n\(jsonString)")
                        print("<<< ... end of response.")
                    }
                case .failure(let error):
                    if self.shouldPrintResponses {
                        print(">>> CCNetworkManager: Request \(stalledRequest.uniqueIdentifier) did finish...")
                        print("    FAILURE: \(error)")
                        print("<<< ... end of response.")
                    }
                }
            #endif
            switch response.result {
            case .success(let data):
                self.lockingQueue.async {
                    self.didFinish(String(describing: Operation.self), bytes: data.count)
                    self.currentBandwidth = Double(data.count) / (response.timeline.requestDuration -
                        response.timeline.latency)
                    #if DEBUG
                        if self.shouldPrintBandwidth {
                            print(">>> CCNetworkManager: Current bandwidth...")
                            print("    Bytes per second:     \(Int(self.currentBandwidth))")
                            print("    Kilobytes per second: \(Int(self.currentBandwidth / 1_000))")
                            print("    Megabytes per second: \(Int(self.currentBandwidth / 1_000_000))")
                            print("<<< ... end of bandwidth.")
                        }
                    #endif
                }
            default:
                break
            }
            self.performRequests()
            }
            .validateStatusCode(accepting: operation.validStatusCodes)
            .catch { error in
                if case WPError.responseError(let data) = error {
                    let err = try operation.processError(from: data)
                    throw err
                }
            }
        return operation.process(data: dataPromise)
    }
    
    private func createRequest<Operation: CCNetworkOperation>(from operation: Operation) throws -> DataRequest {
        switch operation.requestContent {
        case .parameters(data: let parameters, encoding: let encoding):
            var dictionary: [String: Any]? = nil
            if let dict = parameters as? Dictionary<AnyHashable, Any> {
                dictionary = try dict.anyDictionary()
            } else {
                dictionary = try parameters?.anyDictionary()
            }
            return self.sessionManager.request(operation.requestUrl, method: operation.requestMethod,
                                               parameters: dictionary, encoding: encoding, headers: operation.requestHeaders)
        case .data(let data):
            return self.sessionManager.upload(data, to: operation.requestUrl, method: operation.requestMethod,
                                              headers: operation.requestHeaders)
        }
    }
    
    @discardableResult
    private func resumeRequest(_ request: StalledRequest) -> ActiveRequest {
        #if DEBUG
            if self.shouldPrintRequests {
                print(">>> CCNetworkManager: Request \(request.uniqueIdentifier) did start...")
                print("    URL:       \(request.request.request?.url?.absoluteString ?? "<undefined>")")
                print("    Method:    \(request.request.request?.httpMethod ?? "<undefined>")")
                if let headers = request.request.request?.allHTTPHeaderFields, !headers.isEmpty {
                    let jsonString = WPJson(headers).description(forOffset: "\t\t", prettyPrinted: true,
                                                                 truncatesStrings: true)
                    print("    Headers:\n\(jsonString)")
                } else {
                    print("    Headers:   <no header fields>")
                }
                if let data = request.request.request?.httpBody {
                    let jsonString = WPJson(reading: data).description(forOffset: "\t\t", prettyPrinted: true,
                                                                       truncatesStrings: true)
                    print("    JSON Body:\n\(jsonString)")
                } else {
                    print("    JSON Body: <no JSON body>")
                }
                print("<<< ... end of request.")
            }
        #endif
        request.request.resume()
        self.stalledRequests.remove(request)
        self.activeRequests.insert(String(describing: request.identifier))
        return request.identifier
    }
    
    private func estimatedTraffic(for request: ActiveRequest) -> Int {
        if let count = self.statusInformation[request]["count"].intValue,
            let bytes = self.statusInformation[request]["bytes"].intValue {
            #if DEBUG
                if self.shouldPrintEstimatedTraffic {
                    print(">>> CCNetworkManager: Estimated traffic for request \(request)...")
                    print("    Bytes:     \(bytes / count)")
                    print("    Kilobytes: \(Int(bytes / count / 1000))")
                    print("<<< ... end of estimated traffic.")
                }
            #endif
            return bytes / count
        }
        #if DEBUG
            if self.shouldPrintEstimatedTraffic {
                print(">>> CCNetworkManager: Estimated traffic for request \(request)...")
                print("    Bytes:     <unknown>")
                print("    Kilobytes: <unknown>")
                print("<<< ... end of estimated traffic.")
            }
        #endif
        return 1024
    }
    
    private func didFinish(_ request: ActiveRequest, bytes: Int) {
        self.activeRequests.remove(request)
        if let count = self.statusInformation[request]["count"].intValue,
            let oldBytes = self.statusInformation[request]["bytes"].intValue {
            self.statusInformation[request]["count"] = WPJson(count + 1)
            self.statusInformation[request]["bytes"] = WPJson(oldBytes + bytes)
        } else {
            self.statusInformation[request] = WPJson([:])
            self.statusInformation[request]["count"] = WPJson(1)
            self.statusInformation[request]["bytes"] = WPJson(bytes)
        }
        self.performRequests()
    }
    
    private func performRequests() {
        lockingQueue.async {
            // weighing is chosen such that a request is sent with at most 30 seconds delay
            let weighedRequests = self.stalledRequests.lazy
                .map { (request: $0, weighing: $0.priority + Int(30.0 * pow(-$0.dateAdded.timeIntervalSinceNow, 1.5) + 100)) }
            
            let requiredRequests = weighedRequests.filter { $0.weighing >= 5000 }
            requiredRequests.forEach { self.resumeRequest($0.request) }
            
            var estimatedCurrentTraffic = self.activeRequests.reduce(0) { $0 + self.estimatedTraffic(for: $1) }
            
            let sortedRequests = weighedRequests.filter { $0.weighing < 5000 }.sorted { $0.weighing > $1.weighing }
            
            let bandwidth = self.currentBandwidth < 0 ? Int.max : Int(self.currentBandwidth)
            let _ = sortedRequests.prefix { (request, weighing) in
                if estimatedCurrentTraffic > bandwidth {
                    return false
                }
                estimatedCurrentTraffic += self.estimatedTraffic(for: self.resumeRequest(request))
                return true
            }
        }
    }
}

