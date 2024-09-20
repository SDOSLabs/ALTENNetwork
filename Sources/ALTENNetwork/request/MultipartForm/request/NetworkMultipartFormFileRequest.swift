//
//  NetworkMultipartFormFileRequest.swift
//
//  Copyright © 2024 ALTEN. All rights reserved.
//

import Foundation

/// Estructura que representa un archivo a ser enviado en una petición de tipo `multipart/form-data`
/// Esta implementación añade automáticamente la cabecera `Content-Disposition: form-data; name=\"<name>\"`
/// También añade la cabecera `Content-Type: <contentType>`
public struct NetworkMultipartFormFileRequest {
    /// Nombre usado en el key "name" de la cabecera "Content-Disposition
    public let name: String
    
    /// Valor de la solicitud. Generalmente se trata de un archivo
    public let value: Data
    
    /// Nombre del archivo
    public let filename: String
    
    /// Tipo de contenido del archivo. Es el valor que se incluye en la cabecera "Content-Type"
    public let contentType: String
    
    /// Parámetros adicionales de la cabecera "Content-Disposition"
    public let additionalContentDispositionParameters: [NetworkMultipartFormParameterConvertible]?
    
    /// Cabeceras adicionales
    public let additionalHeaders: [NetworkMultipartFormHeaderConvertible]?
    
    /// Inicializador de la solicitud
    /// - Parameters:
    /// - name: Nombre usado en el parámetro "name" de la cabecera "Content-Disposition"
    /// - filename: Nombre del archivo. Es el valor que se incluye en la parámetro "filename" de la cabecera "Content-Disposition"
    /// - value: Valor de la solicitud
    /// - contentType: Tipo de contenido del archivo. Es el valor que se incluye en la cabecera "Content-Type"
    /// - additionalContentDispositionParameters: Parámetros adicionales de la cabecera "Content-Disposition"
    /// - additionalHeaders: Cabeceras adicionales
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
        data.append("\r\n".data(using: .utf8) ?? Data())
        data.append(value)
        data.append("\r\n".data(using: .utf8) ?? Data())
        return data
    }
}
