//
//  NetworkMultipartFormParameter.swift
//
//  Copyright © 2024 ALTEN. All rights reserved.
//

import Foundation

public struct NetworkMultipartFormParameter: NetworkMultipartFormParameterConvertible {
    public let key: String
    public let value: String
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    public func parameter() -> String {
        return "\(key)=\"\(value)\""
    }
}
