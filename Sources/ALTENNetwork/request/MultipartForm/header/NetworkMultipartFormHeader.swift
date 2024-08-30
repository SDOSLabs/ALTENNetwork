//
//  NetworkMultipartFormHeader.swift
//
//  Copyright © 2024 ALTEN. All rights reserved.
//
import Foundation

public struct NetworkMultipartFormHeader: NetworkMultipartFormHeaderConvertible {
    public let key: String
    public let value: String
    public let parameters: [NetworkMultipartFormParameterConvertible]?
    
    public init(key: String, value: String, parameters: [NetworkMultipartFormParameterConvertible]? = nil) {
        self.key = key
        self.value = value
        self.parameters = parameters
    }
    
    public func header() -> String {
        var header = "\(key): \(value)"
        if let parameters, !parameters.isEmpty {
            header.append(
                contentsOf:
                    parameters.reduce("") { (result, parameter) in
                        return "\(result); \(parameter.parameter())"
                    }
            )
        }
        header.append("\r\n")
        return header
    }
}
