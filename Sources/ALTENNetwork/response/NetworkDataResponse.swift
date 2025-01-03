//
//  NetworkDataResponse.swift
//
//  Copyright © 2022 ALTEN. All rights reserved.
//

import Foundation

/// Tipo de dato que normaliza las respuestas de una petición con `NetworkSession`
public struct NetworkDataResponse: Sendable {
    /// Datos devueltos por la petición
    public let data: Data
    /// Response de la petición
    public let response: URLResponse
    /// Request con la que se hizo la petición
    public let originalRequest: URLRequest
    
    /// Crea una instancia de `NetworkDownloadResponse`
    /// - Parameter dataResponse: Tupla con los valores devueltos por la petitición
    public init(dataResponse: (Data, URLResponse), originalRequest: URLRequest) {
        data = dataResponse.0
        response = dataResponse.1
        self.originalRequest = originalRequest
    }
}

extension NetworkDataResponse {
    /// Transforma el `data` del objeto al tipo `Decodable` indicado. `data` deberá ser un `json`
    /// - Parameters:
    ///   - type: tipo de objeto al que se debe trasnformar
    ///   - decoder: instancia de `JSONEncoder` usado para transformar el parámetro `data` a `T`
    /// - Returns: instancia del nuevo tipo de objeto `T`
    public func jsonDecode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        return try ALTENNetwork.jsonDecode(type, data: data, decoder: decoder)
    }
}

extension NetworkDataResponse {
    /// Valida el `statusCode` de la petición en base a los rangos aceptados
    /// - Parameter range: rango de códigos aceptados
    /// - Returns: la misma instancia de `NetworkDownloadResponse`
    public func validate(correctRange range: HTTPCodes = .success) throws -> Self {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.responseData(.invalidResponse(self))
        }
        guard range ~= response.statusCode else {
            throw NetworkError.responseData(.invalidStatusCode(self, response.statusCode))
        }
        return self
    }
    
}
