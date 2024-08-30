//
//  NetworkMultipartFormJsonRequest.swift
//
//  Copyright © 2024 ALTEN. All rights reserved.
//

import Foundation

/// Estructura que representa una petición de tipo `multipart/form-data` con un valor de tipo `Encodable` que será codificado a JSON
/// Esta implementación añade automáticamente la cabecera `Content-Disposition: form-data; name=\"<name>\"`
public struct NetworkMultipartFormJsonRequest<T: Encodable> {
    
    /// Nombre usado en el key "name" de la cabecera "Content-Disposition"
    public let name: String
    
    /// Valor de la solicitud
    public let value: T
    
    /// Instancia de `JSONEncoder` usado para transformar el valor de la solicitud a JSON
    public let encoder: JSONEncoder
    
    /// Parámetros adicionales de la cabecera "Content-Disposition"
    public let additionalContentDispositionParameters: [NetworkMultipartFormParameterConvertible]?
    
    /// Cabeceras adicionales
    public let additionalHeaders: [NetworkMultipartFormHeaderConvertible]?
    
    /// Inicializador de la solicitud
    /// - Parameters:
    /// - name: Nombre usado en el parámetro "name" de la cabecera "Content-Disposition"
    /// - value: Valor de la solicitud
    /// - encoder: Instancia de `JSONEncoder` usado para transformar el valor de la solicitud a JSON
    /// - additionalContentDispositionParameters: Parámetros adicionales de la cabecera "Content-Disposition"
    /// - additionalHeaders: Cabeceras adicionales
    public init(name: String,
                value: T,
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
