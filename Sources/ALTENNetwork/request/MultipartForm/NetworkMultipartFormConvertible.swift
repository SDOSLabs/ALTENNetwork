//
//  NetworkMultipartFormConvertible.swift
//
//  Copyright © 2024 ALTEN. All rights reserved.
//

import Foundation

/// Protocolo que permite convertir cualquier tipo de dato a un tipo `Data` para ser enviado en una petición de tipo `multipart/form-data`
public protocol NetworkMultipartFormDataConvertible {
    func data(boundary: String) throws -> Data
}

/// Protocolo que permite convertir cualquier tipo de dato a un tipo `String` para ser enviado en una petición de tipo `multipart/form-data` como parte de los parámetros de una cabecera
/// Ejemplo: `name="value"`
public protocol NetworkMultipartFormParameterConvertible {
    func parameter() -> String
}

/// Protocolo que permite convertir cualquier tipo de dato a un tipo `String` para ser enviado en una petición de tipo `multipart/form-data` como parte de su cabecera
/// Ejemplo: `Creation-Date: 1999-01-01\r\n`
public protocol NetworkMultipartFormHeaderConvertible {
    func header() -> String
}
