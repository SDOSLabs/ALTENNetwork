//
//  URLRequest+Network.swift
//
//  Copyright © 2023 ALTEN. All rights reserved.
//

import Foundation

extension URLRequest {
    public var curl: String {
        var result = "curl -k "
        
        if let method = httpMethod {
            result += "-X \(method) \\\n"
        }
        
        if let headers = allHTTPHeaderFields {
            for (header, value) in headers {
                result += "-H \"\(header): \(value)\" \\\n"
            }
        }
        
        if let body = httpBody, !body.isEmpty, let string = String(data: body, encoding: .utf8), !string.isEmpty {
            result += "-d '\(string)' \\\n"
        }
        
        if let url = url {
            result += url.absoluteString
        }
        
        return result
    }
    
    public func curlWithSession(_ session: URLSession) -> String {
        var result = "curl -k "
        
        if let method = httpMethod {
            result += "-X \(method) \\\n"
        }
        
        if var headers = allHTTPHeaderFields {
            if let sessionHeaders = session.configuration.httpAdditionalHeaders as? [String: String] {
                headers = headers.merging(sessionHeaders) { (current, _) in current }
            }
            for (header, value) in headers {
                result += "-H \"\(header): \(value)\" \\\n"
            }
        }
        
        if let body = httpBody, !body.isEmpty, let string = String(data: body, encoding: .utf8), !string.isEmpty {
            result += "-d '\(string)' \\\n"
        }
        
        if let url = url {
            result += url.absoluteString
        }
        
        return result
    }
}
