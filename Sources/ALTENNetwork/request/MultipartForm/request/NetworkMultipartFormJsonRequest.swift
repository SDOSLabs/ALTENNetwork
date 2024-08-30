//
//  NetworkMultipartFormJsonRequest.swift
//
//  Copyright © 2024 ALTEN. All rights reserved.
//

import Foundation

public struct NetworkMultipartFormJsonRequest<T: Encodable> {
    public let name: String
    public let value: T
    public let encoder: JSONEncoder
    public let additionalContentDispositionParameters: [NetworkMultipartFormParameterConvertible]?
    public let additionalHeaders: [NetworkMultipartFormHeaderConvertible]?
    
    public init(name: String, value: T,
                encoder: JSONEncoder = JSONEncoder(),
                additionalContentDispositionParameters: [NetworkMultipartFormParameterConvertible]? = nil,
                additionalHeaders: [NetworkMultipartFormHeaderConvertible]? = nil) {
        self.name = name
        self.value = value
        self.encoder = encoder
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
                    NetworkMultipartFormParameter(key: "name", value: name)
                ] + (additionalContentDispositionParameters ?? [])
            )
        )
        headers.append(contentsOf: additionalHeaders ?? [])
        return headers.reduce("") { (result, header) in
            return "\(result)\(header.header())"
        }
    }
}

extension NetworkMultipartFormJsonRequest: NetworkMultipartFormDataConvertible {
    public func data(boundary: String) throws -> Data {
        do {
            let jsonData = try encoder.encode(value)
            var data = Data()
            data.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
            data.append(generateHeaders().data(using: .utf8) ?? Data())
            data.append(jsonData)
            data.append("\r\n".data(using: .utf8) ?? Data())
            return data
        } catch {
            throw NetworkError.request(.encodeError(error))
        }
    }
}
