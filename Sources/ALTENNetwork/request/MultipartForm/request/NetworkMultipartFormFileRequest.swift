//
//  NetworkMultipartFormFileRequest.swift
//
//  Copyright © 2024 ALTEN. All rights reserved.
//

import Foundation

public struct NetworkMultipartFormFileRequest {
    public let name: String
    public let value: Data
    public let filename: String
    public let contentType: String
    public let additionalContentDispositionParameters: [NetworkMultipartFormParameterConvertible]?
    public let additionalHeaders: [NetworkMultipartFormHeaderConvertible]?
    
    public init(name: String,
                filename: String,
                value: Data,
                contentType: String,
                additionalContentDispositionParameters: [NetworkMultipartFormParameterConvertible]? = nil,
                additionalHeaders: [NetworkMultipartFormHeaderConvertible]? = nil) {
        self.name = name
        self.value = value
        self.filename = filename
        self.contentType = contentType
        self.additionalContentDispositionParameters = additionalContentDispositionParameters
        self.additionalHeaders = additionalHeaders
    }
    
    private func generateHeaders() -> String {
        var headers = [NetworkMultipartFormHeaderConvertible]()
        headers.append(
            NetworkMultipartFormHeader(
                key: "Content-Disposition",
                value: "form-data",
                parameters: [
                    NetworkMultipartFormParameter(key: "name", value: name),
                    NetworkMultipartFormParameter(key: "filename", value: filename)
                ] + (additionalContentDispositionParameters ?? [])
            )
        )
        headers.append(NetworkMultipartFormHeader(key: "Content-Type", value: contentType))
        headers.append(contentsOf: additionalHeaders ?? [])
        return headers.reduce("") { (result, header) in
            return "\(result)\(header.header())"
        }
    }
}

extension NetworkMultipartFormFileRequest: NetworkMultipartFormDataConvertible {
    public func data(boundary: String) throws -> Data {
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
        data.append(generateHeaders().data(using: .utf8) ?? Data())
        data.append(value)
        data.append("\r\n".data(using: .utf8) ?? Data())
        return data
    }
}
