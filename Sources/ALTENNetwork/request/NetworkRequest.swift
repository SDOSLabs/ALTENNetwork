//
//  NetworkRequest.swift
//
//  Copyright © 2022 ALTEN. All rights reserved.
//

import Foundation

open class NetworkRequest {
    public let urlRequest: URLRequest
    
    /// Crea un `NetworkRequest` a partir de unos parámetros
    /// - Parameters:
    ///   - url: url de la petición
    ///   - httpMethod: método http de la petición
    ///   - headers: cabeceras de la petición
    ///   - query: parámetros de tipo query de la petición
    ///   - httpBody: parámetros del body de la petición
    public init(url: URL,
                httpMethod: NetworkHttpMethod = .get,
                headers: [NetworkHeader]? = nil,
                query: [NetworkQuery]? = nil,
                httpBody: Data? = nil) throws {
        
        guard var components = URLComponents(string: url.absoluteString) else { throw NetworkError.request(.invalidURL) }
        if let query = query {
            components.queryItems = (components.queryItems ?? []) + query.compactMap { $0.asURLQueryItem() }
            components.percentEncodedQueryItems = components.percentEncodedQueryItems?.compactMap { item in
                if let query = query.first(where: { $0.key == item.name }), query.forceEncodingPlusSymbol {
                    return URLQueryItem(name: item.name, value: item.value?.replacingOccurrences(of: "+", with: "%2B"))
                } else {
                    return item
                }
            }
            
        }
        guard let url = components.url else { throw NetworkError.request(.invalidURL) }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers?.reduce(into: [:], { (result, item) in result[item.key] = item.value })
        urlRequest.httpBody = httpBody
        
        self.urlRequest = urlRequest
    }
    
    /// Crea un `NetworkRequest` a partir de unos parámetros
    /// - Parameters:
    ///   - url: url de la petición
    ///   - httpMethod: método http de la petición
    ///   - headers: cabeceras de la petición
    ///   - query: parámetros de tipo query de la petición
    ///   - httpBody: parámetros del body de la petición
    public convenience init(url: String,
                            httpMethod: NetworkHttpMethod = .get,
                            headers: [NetworkHeader]? = nil,
                            query: [NetworkQuery]? = nil,
                            httpBody: Data? = nil) throws {
        guard let url = URL(string: url) else { throw NetworkError.request(.invalidURL) }
        try self.init(url: url, httpMethod: httpMethod, headers: headers, query: query, httpBody: httpBody)
    }
    
    /// Crea un `NetworkRequest` a partir de unos parámetros. Este inicializador añade la cabecera `Content-Type: application/json` automáticamente a la petición
    /// - Parameters:
    ///   - url: url de la petición
    ///   - httpMethod: método http de la petición
    ///   - headers: cabeceras de la petición
    ///   - query: parámetros de tipo query de la petición
    ///   - jsonBody: objeto `Encodable` que será transformado a `json` y añadido al body de la petición
    ///   - encoder: instancia de `JSONEncoder` usado para transformar el parámetro `jsonBody` a `json`
    public convenience init<T: Encodable>(url: URL,
                                          httpMethod: NetworkHttpMethod,
                                          headers: [NetworkHeader]? = nil,
                                          query: [NetworkQuery]? = nil,
                                          jsonBody: T? = nil,
                                          encoder: JSONEncoder = JSONEncoder(outputFormatting: .sortedKeys)) throws {
        var httpBodyData: Data?
        if let jsonBody = jsonBody {
            do {
                httpBodyData = try encoder.encode(jsonBody)
            } catch {
                throw NetworkError.request(.encodeError(error))
            }
        }
        try self.init(url: url, httpMethod: httpMethod, headers: [NetworkHeader(key: "Content-Type", value: "application/json")] + (headers ?? []), query: query, httpBody: httpBodyData)
    }
    
    /// Crea un `NetworkRequest` a partir de unos parámetros. Este inicializador añade la cabecera `Content-Type: application/json` automáticamente a la petición
    /// - Parameters:
    ///   - url: url de la petición
    ///   - httpMethod: método http de la petición
    ///   - headers: cabeceras de la petición
    ///   - query: parámetros de tipo query de la petición
    ///   - jsonBody: objeto `Encodable` que será transformado a `json` y añadido al body de la petición
    ///   - encoder: instancia de `JSONEncoder` usado para transformar el parámetro `jsonBody` a `json`
    public convenience init<T: Encodable>(url: String,
                                          httpMethod: NetworkHttpMethod,
                                          headers: [NetworkHeader]? = nil,
                                          query: [NetworkQuery]? = nil,
                                          jsonBody: T? = nil,
                                          encoder: JSONEncoder = JSONEncoder(outputFormatting: .sortedKeys)) throws {
        guard let url = URL(string: url) else { throw NetworkError.request(.invalidURL) }
        try self.init(url: url, httpMethod: httpMethod, headers: headers, query: query, jsonBody: jsonBody, encoder: encoder)
    }
    
    /// Crea un `NetworkRequest` a partir de unos parámetros. Este inicializador añade la cabecera `Content-Type: multipart/form-data` automáticamente a la petición
    ///  - Parameters:
    ///  - url: url de la petición
    ///  - httpMethod: método http de la petición
    ///  - headers: cabeceras de la petición
    ///  - query: parámetros de tipo query de la petición
    ///  - multipartForm: parámetros de tipo `NetworkMultipartFormDataConvertible` que serán añadidos al body de la petición
    public convenience init(url: String,
                            httpMethod: NetworkHttpMethod,
                            headers: [NetworkHeader]? = nil,
                            query: [NetworkQuery]? = nil,
                            multipartForm: [NetworkMultipartFormDataConvertible]) throws {
        guard let url = URL(string: url) else { throw NetworkError.request(.invalidURL) }
        try self.init(url: url, httpMethod: httpMethod, headers: headers, query: query, multipartForm: multipartForm)
    }
    /// Crea un `NetworkRequest` a partir de unos parámetros. Este inicializador añade la cabecera `Content-Type: multipart/form-data` automáticamente a la petición
    /// - Parameters:
    ///  - url: url de la petición
    ///  - httpMethod: método http de la petición
    ///  - headers: cabeceras de la petición
    ///  - query: parámetros de tipo query de la petición
    ///  - multipartForm: parámetros de tipo `NetworkMultipartFormDataConvertible` que serán añadidos al body de la petición
    public convenience init(url: URL,
                            httpMethod: NetworkHttpMethod,
                            headers: [NetworkHeader]? = nil,
                            query: [NetworkQuery]? = nil,
                            multipartForm: [NetworkMultipartFormDataConvertible]) throws {
        var httpBodyData: Data = Data()
        let boundary = "Boundary-\(UUID().uuidString)"
        guard let boundaryData = "--\(boundary)\r\n".data(using: .utf8) else {
            throw NetworkError.request(.stringEncodingError)
        }
        if !multipartForm.isEmpty {
            httpBodyData.append(
                try multipartForm.reduce(into: Data()) { (result, item) in
                    do {
                        let data = try item.data(boundary: boundary)
                        result.append(data)
                    } catch {
                        throw NetworkError.request(.encodeError(error))
                    }
                }
            )
            httpBodyData.append(boundaryData)
        }
        
        try self.init(url: url, httpMethod: httpMethod, headers: [NetworkHeader(key: "Content-Type", value: "multipart/form-data; boundary=\(boundary)")] + (headers ?? []), query: query, httpBody: httpBodyData)
    }
    
    /// Crea un `NetworkRequest` a partir de un `URLRequest`
    /// - Parameter urlRequest: `URLRequest` con la petición
    public init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
}

extension NetworkRequest: URLRequestConvertible {
    /// Convierte el objeto al tipo `URLRequest`
    /// - Returns: url de la petición
    public func asURLRequest() -> URLRequest {
        return urlRequest
    }
}

