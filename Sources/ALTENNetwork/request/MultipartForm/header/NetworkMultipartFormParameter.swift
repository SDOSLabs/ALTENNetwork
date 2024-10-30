//
//  NetworkMultipartFormParameter.swift
//
//  Copyright © 2024 ALTEN. All rights reserved.
//

import Foundation

/// Estructura que representa un parámetro de una petición de tipo `multipart/form-data`
public struct NetworkMultipartFormParameter: NetworkMultipartFormParameterConvertible {
    
    /// Clave del parámetro
    public let key: String
    
    /// Valor del parámetro
    public let value: String
    
    /// Inicializador del parámetro
    /// - Parameters:
    /// - key: Clave del parámetro
    /// - value: Valor del parámetro
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    /// Genera la cadena de texto del parámetro
    /// - Returns: Cadena de texto del parámetro
    /// - Ejemplo:
    /// Para un parámetro con los siguientes valores:
    /// ```
    /// NetworkMultipartFormParameter(key: "name", value: "file")
    /// ```
    /// El resultado sería:
    /// ```
    /// name="file"
    /// ```
    public func parameter() -> String {
        return "\(key)=\"\(value)\""
    }
}
