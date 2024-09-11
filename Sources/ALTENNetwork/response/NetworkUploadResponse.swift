//
//  NetworkUploadResponse.swift
//
//  Copyright © 2022 ALTEN. All rights reserved.
//

import Foundation

/// Tipo de dato que normaliza las respuestas de una petición de subida con `NetworkSession`
public struct NetworkUploadResponse: Sendable {
    /// Datos devueltos por la petición
    public let data: Data
    /// Response de la petición
    public let response: URLResponse
    /// Request con la que se hizo la petición
    public let originalRequest: URLRequest
    /// Tipo de subida de la petición
    public let uploadType: UploadType
    
    public enum UploadType: Sendable {
        case data(Data)
        case file(URL)
    }
    
    /// Crea una instancia de `NetworkUploadResponse`
    /// - Parameter dataResponse: Tupla con los valores devueltos por la petitición
    public init(dataResponse: (Data, URLResponse), originalRequest: URLRequest, uploadType: UploadType) {
        data = dataResponse.0
        response = dataResponse.1
        self.originalRequest = originalRequest
        self.uploadType = uploadType
    }
}


extension NetworkUploadResponse {
    /// Transforma el `data` del objeto al tipo `Decodable` indicado. `data` deberá ser un `json`
    /// - Parameters:
    ///   - type: tipo de objeto al que se debe trasnformar
    ///   - decoder: instancia de `JSONEncoder` usado para transformar el parámetro `data` a `T`
    /// - Returns: instancia del nuevo tipo de objeto `T`
    public func jsonDecode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        return try ALTENNetwork.jsonDecode(type, data: data, decoder: decoder)
    }
}


extension NetworkUploadResponse {
    /// Valida el `statusCode` de la petición en base a los rangos aceptados
    /// - Parameter range: rango de códigos aceptados
    /// - Returns: la misma instancia de `NetworkUploadResponse`
    public func validate(correctRange range: HTTPCodes = .success) throws -> Self {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.responseUpload(.invalidResponse(self))
        }
        guard range ~= response.statusCode else {
            throw NetworkError.responseUpload(.invalidStatusCode(self, response.statusCode))
        }
        return self
    }
}
