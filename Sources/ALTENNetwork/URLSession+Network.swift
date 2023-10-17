//
//  URLSession+Network.swift
//
//  Copyright © 2022 ALTEN. All rights reserved.
//

import Foundation

extension URLSession {
    /// Descarga el contenido de un `URLRequestConvertible` y lo almacena en memoria. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la descarga del contenido
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    public func requestData(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        return try await _requestData(for: request, delegate: delegate)
    }
    
    /// Descarga el contenido de un `URLRequestConvertible` y lo almacena en memoria. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la descarga del contenido
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    public func requestData(for request: URLRequestConvertible) async throws -> NetworkDataResponse {
        return try await _requestData(for: request, delegate: nil)
    }
    
    /// Descarga el contenido de una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    public func requestData(for str: String, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestData(for: url, delegate: delegate)
    }
    
    /// Descarga el contenido de una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    public func requestData(for str: String) async throws -> NetworkDataResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestData(for: url)
    }
    
    private func _requestData(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        let urlRequest = request.asURLRequest()
        if #available(iOS 15, tvOS 15, *) {
            return try await NetworkDataResponse(dataResponse: self.data(for: urlRequest, delegate: delegate), originalRequest: urlRequest)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                let dataTask = self.dataTask(with: urlRequest) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: NetworkDataResponse(dataResponse: (data, response), originalRequest: urlRequest))
                    } else {
                        continuation.resume(throwing: NetworkError.unknown)
                    }
                    
                }
                dataTask.resume()
            }
        }
    }
}

extension URLSession {
    
    /// Descarga el contenido de un `URLRequestConvertible` y lo almacena en un fichero en disco. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la descarga del contenido
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `URL` con la ruta del contenido descargado y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    public func requestDownload(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?) async throws -> NetworkDownloadResponse {
        return try await _requestDownload(for: request, delegate: delegate)
    }
    
    /// Descarga el contenido de un `URLRequestConvertible` y lo almacena en un fichero en disco. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la descarga del contenido
    /// - Returns: Respuesta del servidor que contiene `URL` con la ruta del contenido descargado y `URLResponse`
    public func requestDownload(for request: URLRequestConvertible) async throws -> NetworkDownloadResponse {
        return try await _requestDownload(for: request, delegate: nil)
    }
    
    /// Descarga el contenido de una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `URL` con la ruta del contenido descargado y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    public func requestDownload(for str: String, delegate: URLSessionTaskDelegate?) async throws -> NetworkDownloadResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestDownload(for: url, delegate: delegate)
    }
    
    /// Descarga el contenido de una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    /// - Returns: Respuesta del servidor que contiene `URL` con la ruta del contenido descargado y `URLResponse`
    public func requestDownload(for str: String) async throws -> NetworkDownloadResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestDownload(for: url)
    }
    
    private func _requestDownload(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?) async throws -> NetworkDownloadResponse {
        let urlRequest = request.asURLRequest()
        if #available(iOS 15, tvOS 15, *) {
            return try await NetworkDownloadResponse(dataResponse: self.download(for: urlRequest, delegate: delegate), originalRequest: urlRequest)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                let dataTask = self.downloadTask(with: urlRequest) { url, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let url = url, let response = response {
                        continuation.resume(returning: NetworkDownloadResponse(dataResponse: (url, response), originalRequest: urlRequest))
                    } else {
                        continuation.resume(throwing: NetworkError.unknown)
                    }
                    
                }
                dataTask.resume()
            }
        }
    }
    
}

extension URLSession {
    
    // Realiza la subida de contenido a un `URLRequestConvertible`. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la subida del contenido
    ///   - bodyData: `Data` que debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    public func requestUpload(for request: URLRequestConvertible, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        return try await _requestUpload(for: request, from: bodyData, delegate: delegate)
    }
    
    /// Realiza la subida de contenido a un `URLRequestConvertible`. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la subida del contenido
    ///   - bodyData: `Data` que debe enviar al servidor
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    public func requestUpload(for request: URLRequestConvertible, from bodyData: Data) async throws -> NetworkDataResponse {
        return try await _requestUpload(for: request, from: bodyData, delegate: nil)
    }
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - bodyData: `Data` que debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    public func requestUpload(for str: String, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestUpload(for: url, from: bodyData, delegate: delegate)
    }
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - bodyData: `Data` que debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    public func requestUpload(for str: String, from bodyData: Data) async throws -> NetworkDataResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestUpload(for: url, from: bodyData)
    }
    
    private func _requestUpload(for request: URLRequestConvertible, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        let urlRequest = request.asURLRequest()
        if #available(iOS 15, tvOS 15, *) {
            return try await NetworkDataResponse(dataResponse: self.upload(for: urlRequest, from: bodyData, delegate: delegate), originalRequest: urlRequest)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                let dataTask = self.uploadTask(with: urlRequest, from: bodyData) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: NetworkDataResponse(dataResponse: (data, response), originalRequest: urlRequest))
                    } else {
                        continuation.resume(throwing: NetworkError.unknown)
                    }
                    
                }
                dataTask.resume()
            }
        }
    }
}

extension URLSession {
    
    /// Realiza la subida de contenido a un `URLRequestConvertible`. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la subida del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    public func requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        return try await _requestUpload(for: request, fromFile: fileURL, delegate: delegate)
    }
    
    /// Realiza la subida de contenido a un `URLRequestConvertible`. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la subida del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    public func requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL) async throws -> NetworkDataResponse {
        return try await _requestUpload(for: request, fromFile: fileURL, delegate: nil)
    }
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    public func requestUpload(for str: String, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestUpload(for: url, fromFile: fileURL, delegate: delegate)
    }
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    public func requestUpload(for str: String, fromFile fileURL: URL) async throws -> NetworkDataResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestUpload(for: url, fromFile: fileURL)
    }
    
    private func _requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        let urlRequest = request.asURLRequest()
        if #available(iOS 15, tvOS 15, *) {
            return try await NetworkDataResponse(dataResponse: self.upload(for: urlRequest, fromFile: fileURL, delegate: delegate), originalRequest: urlRequest)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                let dataTask = self.uploadTask(with: urlRequest, fromFile: fileURL) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: NetworkDataResponse(dataResponse: (data, response), originalRequest: urlRequest))
                    } else {
                        continuation.resume(throwing: NetworkError.unknown)
                    }
                    
                }
                dataTask.resume()
            }
        }
    }
}
