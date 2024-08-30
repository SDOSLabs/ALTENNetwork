//
//  NetworkMultipartFormHeader.swift
//
//  Copyright © 2024 ALTEN. All rights reserved.
//
import Foundation

/// Estructura que representa una cabecera de una petición de tipo `multipart/form-data`
public struct NetworkMultipartFormHeader: NetworkMultipartFormHeaderConvertible {
    
    /// Clave de la cabecera
    public let key: String
    
    /// Valor de la cabecera
    public let value: String
    
    /// Parámetros adicionales de la cabecera
    public let parameters: [NetworkMultipartFormParameterConvertible]?
    
    /// Inicializador de la cabecera
    /// - Parameters:
    ///  - key: Clave de la cabecera
    ///  - value: Valor de la cabecera
    ///  - parameters: Parámetros adicionales
    public init(key: String, value: String, parameters: [NetworkMultipartFormParameterConvertible]? = nil) {
        self.key = key
        self.value = value
        self.parameters = parameters
    }
    
    /// Genera la cadena de texto de la cabecera
    /// - Returns: Cadena de texto de la cabecera
    /// - Ejemplo:
    /// Para una cabecera con los siguientes valores:
    /// ```
    /// NetworkMultipartFormHeader(key: "Content-Disposition", value: "form-data", parameters: [
    ///    NetworkMultipartFormParameter(key: "name", value: "file"),
    ///    NetworkMultipartFormParameter(key: "filename", value: "file.png")
    /// ])
    /// ```
    ///
    ///    El resultado sería:
    /// ```
    /// Content-Disposition: form-data; name="file"; filename="file.png"
    /// ```
    /// 
    ///
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
