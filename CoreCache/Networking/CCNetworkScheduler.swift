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

open class CCNetworkScheduler {
    
    #if DEBUG
        public var printsOutgoingData = true
        public var printsIncomingData = true
        public var printsBandwidth = false
        public var printsEstimatedTraffic = false
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
        
        let request: DataRequest
        let priority: Int
        let dateAdded: Date
        let identifier: String
        
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
    
    static private(set) var `default` = CCNetworkScheduler()
    
    public var httpHeaders: CCNetworkHeaders = SessionManager.defaultHTTPHeaders
    
    private let sessionManager: SessionManager
    private let lockingQueue = DispatchQueue(label: "", qos: .userInitiated)
    
    private lazy var statusInformation: WPJson = {
        if !FileManager.default.fileExists(atPath: self.statusInformationUrl.absoluteString) {
            return WPJson([:])
        }
        return WPJson(readingFrom: self.statusInformationUrl)
    }()
    
    private var statusInformationUrl: URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return url.appendingPathComponent("cccache").appendingPathComponent("ccnetworkscheduler").appendingPathComponent("info.json")
    }
    
    private var stalledRequests = Set<StalledRequest>()
    private var activeRequests = Set<ActiveRequest>()
    private var currentBandwidth = -1.0 // byte/s
    
    private init() {
        let configuration = URLSessionConfiguration()
        configuration.httpAdditionalHeaders = httpHeaders
        sessionManager = SessionManager(configuration: configuration)
        sessionManager.startRequestsImmediately = false
        sessionManager.session.configuration.timeoutIntervalForResource = 120
        sessionManager.session.configuration.timeoutIntervalForRequest = 30
    }
    
    public func request<Operation: CCNetworkOperation>(_ operation: Operation, priority: RequestPriority = .required,
                                                       progressHandler: @escaping (Int) -> Void = { _ in return }) -> CPPromise<Operation.ResultType> {
        return CPPromise { resolve, reject in
            let request = self.createRequest(from: operation)
            request.downloadProgress { progress in
                progressHandler(Int(progress.fractionCompleted * 100))
            }
            #if DEBUG
                if self.printsIncomingData {
                    request.print()
                }
            #endif
            request.responseData { response in
                switch response.result {
                case .success(let data):
                    self.lockingQueue.async {
                        self.didFinish(String(describing: Operation.self), bytes: data.count)
                        self.currentBandwidth = Double(data.count) / (response.timeline.requestDuration -
                            response.timeline.latency)
                        #if DEBUG
                            if self.printsBandwidth {
                                print("Request '\(String(describing: Operation.self))' did finish.")
                                print("Current bandwidth is \(self.currentBandwidth) bytes per second.")
                            }
                        #endif
                    }
                    self.performRequests()
                case .failure(let error):
                    self.performRequests()
                    reject(error)
                }
            }
            self.lockingQueue.async {
                let stalledRequest = StalledRequest(request, priority: priority, identifier: String(describing: Operation.self))
                self.stalledRequests.insert(stalledRequest)
                self.performRequests()
            }
            resolve(request)
        }.then { request in operation.serialize(request) }
    }
    
    open func parseError(using data: Data) -> Error {
        return CCNetworkError.invalidStatusCode(WPJson(reading: data))
    }
    
    private func createRequest<Operation: CCNetworkOperation>(from operation: Operation) -> DataRequest {
        switch operation.requestContent {
        case .parameters(data: let parameters, encoding: let encoding):
            return self.sessionManager.request(operation.requestUrl, method: operation.requestMethod,
                                               parameters: parameters, encoding: encoding, headers: operation.requestHeaders)
        case .data(let data):
            return self.sessionManager.upload(data, to: operation.requestUrl, method: operation.requestMethod,
                                              headers: operation.requestHeaders)
        }
    }
    
    @discardableResult
    private func resumeRequest(_ request: StalledRequest) -> ActiveRequest {
        #if DEBUG
            if self.printsOutgoingData {
                print("+++ Request '\(request.identifier)' did start.")
                print("\tURL: '\(request.request.request?.url?.absoluteString ?? "<unspecified>")'")
                if let body = request.request.request?.httpBody, let string = String(data: body, encoding: .utf8) {
                    print("\tHTTP Body: \(string)")
                } else {
                    print("\tHTTP Body: <unspecified>")
                }
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
                if self.printsEstimatedTraffic {
                    print("Estimated traffic for request '\(request)' is \(bytes / count) bytes.")
                }
            #endif
            return bytes / count
        }
        #if DEBUG
            if self.printsEstimatedTraffic {
                print("Estimated traffic for request '\(request)' is currently unknown.")
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
            self.statusInformation[request]["count"] = WPJson(bytes)
        }
        self.performRequests()
    }
    
    private func performRequests() {
        lockingQueue.async {
            // weighing is chosen such that a request is sent with at most 30 seconds delay
            let weighedRequests = self.stalledRequests.lazy
                .map { (request: $0, weighing: $0.priority + Int(30.0 * pow(-$0.dateAdded.timeIntervalSinceNow, 1.5) + 100)) }
            
            let requiredRequests = weighedRequests.filter { $0.weighing >= 5000 }
            let _ = requiredRequests.map { self.resumeRequest($0.request) }
            
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
    
    deinit {
        try? statusInformation.data()?.write(to: self.statusInformationUrl)
    }
    
}
