//
//  NetworkMultipartFormConvertible.swift
//
//  Copyright © 2024 ALTEN. All rights reserved.
//

import Foundation

public protocol NetworkMultipartFormDataConvertible {
    func data(boundary: String) throws -> Data
}

public protocol NetworkMultipartFormParameterConvertible {
    func parameter() -> String
}

public protocol NetworkMultipartFormHeaderConvertible {
    func header() -> String
}
