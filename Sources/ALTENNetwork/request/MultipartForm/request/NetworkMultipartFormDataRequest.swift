//
//  NetworkMultipartFormDataRequest.swift
//
//  Copyright © 2024 ALTEN. All rights reserved.
//

import Foundation

/// Estructura que representa una solicitud de tipo multipart/form-data de datos
/// Esta implementación añade automáticamente la cabecera `Content-Disposition: form-data; name=\"<name>\"`
public struct NetworkMultipartFormDataRequest {
    /// Nombre usado en la key "name" de la cabecera "Content-Disposition"
    public let name: String
    
    /// Valor de la solicitud
    public let value: Data
    
    /// Parámetros adicionales de la cabecera "Content-Disposition"
    public let additionalContentDispositionParameters: [NetworkMultipartFormParameterConvertible]?
    
    /// Cabeceras adicionales
    public let additionalHeaders: [NetworkMultipartFormHeaderConvertible]?
    
    /// Inicializador de la solicitud
    /// - Parameters:
    ///  - name: Nombre usado en el parámetro "name" de la cabecera "Content-Disposition"
    ///  - value: Valor de la solicitud
    ///  - additionalContentDispositionParameters: Parámetros adicionales de la cabecera "Content-Disposition"
    ///  - additionalHeaders: Cabeceras adicionales
    public init(name: String,
                value: Data,
                additionalContentDispositionParameters: [NetworkMultipartFormParameterConvertible]? = nil,
                additionalHeaders: [NetworkMultipartFormHeaderConvertible]? = nil) {
        self.name = name
        self.value = value
        self.additionalContentDispositionParameters = additionalContentDispositionParameters
        self.additionalHeaders = additionalHeaders
    }
    
    private func generateHeaders() -> String {
        var headers = [NetworkMultipartFormHeaderConvertible]()
        headers.append(
            NetworkMultipartFormHeader(
                key: "Content-Disposition",
                value: "form-data",
                parameters: [NetworkMultipartFormParameter(key: "name", value: name)] + (additionalContentDispositionParameters ?? [])
            )
        )
        headers.append(contentsOf: additionalHeaders ?? [])
        return headers.reduce("") { (result, header) in
            return "\(result)\(header.header())"
        }
    }
}

extension NetworkMultipartFormDataRequest: NetworkMultipartFormDataConvertible {
    public func data(boundary: String) throws -> Data {
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
        data.append(generateHeaders().data(using: .utf8) ?? Data())
        data.append(value)
        data.append("\r\n".data(using: .utf8) ?? Data())
        return data
    }
}
