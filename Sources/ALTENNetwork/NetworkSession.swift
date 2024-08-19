//
//  NetworkSession.swift
//
//  Copyright © 2023 ALTEN. All rights reserved.
//

import Foundation

/// Enumerado que contiene los tipos de intercepción que se pueden realizar
public enum NetworkSessionInterceptionResult {
    case nothing
    case retry(URLRequestConvertible)
}

/// Enumerado que contiene los tipos de intercepción que se pueden realizar
public enum NetworkSessionInterception {
    case data(NetworkDataResponse)
    case download(NetworkDownloadResponse)
    case upload(NetworkUploadResponse)
}

/// Contiene todos los métodos disponibles para realizar llamadas con async/await
public protocol NetworkSession {
    
    /// Inicializador de la clase
    /// - Parameter session: `URLSession` que se encargará de realizar
    init(session: URLSession)
    
    /// `URLSession` que se encarga de realizar las peticiones
    var session: URLSession { get set }
    
    /// Este método se llamará cuando se finalice cualquier request. Tiene como parámetro de entrada el `NetworkSession` que realiza la petición y la `URLRequest` original a la que se está llamando.
    /// Este método permite interceptar la respuesta antes de continuar con el flujo, pudiendo forzar el reintento de la petición con una nueva `URLRequest`
    /// Por ejemplo, se puede usar para controlar los códigos de error 401, permitiendo realizar el refresco de un token y reintentar la petición
    /// - Parameters:
    ///  - result: Resultado de la petición. En caso de que la petición haya tenido respuesta del servidor contendrá un `NetworkSessionInterception`. En cualquier otro caso contendrá un `Error`
    ///  - networkSession: `NetworkSession` que realiza la petición
    ///  - originalRequest: `URLRequest` original a la que se está llamando
    ///  - retryNumber: Número de intentos que se han realizado para la petición. El primer intento es 0.
    ///  - Returns: `NetworkSessionInterceptionResult` que indica si se debe continuar con el flujo o si se debe reintentar la petición con una nueva `URLRequest`
    func interceptResponse(networkSession: NetworkSession, originalRequest: URLRequest, retryNumber: Int, result: Result<NetworkSessionInterception, Error>) async throws -> NetworkSessionInterceptionResult
    
    /// Este método se llamará antes de que comience cualquier request. Tiene como parámetro de entrada la URLRequest a la que se está llamando y su único objetivo es que sirva de caracter informativo.
    /// La implementación por defecto imprime el curl de la request sólo en entornos de debug a través de la condificón `#if DEBUG`
    /// - Parameters:
    /// - networkSession: `NetworkSession` que realiza la petición
    /// - originalRequest: `URLRequest` original a la que se está llamando
    func requestStart(networkSession: NetworkSession, originalRequest: URLRequest)
    
    // Descarga el contenido de un `URLRequestConvertible` y lo almacena en memoria. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la descarga del contenido
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    func requestData(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse
    
    /// Descarga el contenido de un `URLRequestConvertible` y lo almacena en memoria. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la descarga del contenido
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    func requestData(for request: URLRequestConvertible) async throws -> NetworkDataResponse
    
    /// Descarga el contenido de una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    func requestData(for str: String, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse
    
    /// Descarga el contenido de una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    func requestData(for str: String) async throws -> NetworkDataResponse
    
    /// Descarga el contenido de un `URLRequestConvertible` y lo almacena en un fichero en disco. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la descarga del contenido
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `URL` con la ruta del contenido descargado y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    func requestDownload(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?) async throws -> NetworkDownloadResponse
    
    /// Descarga el contenido de un `URLRequestConvertible` y lo almacena en un fichero en disco. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la descarga del contenido
    /// - Returns: Respuesta del servidor que contiene `URL` con la ruta del contenido descargado y `URLResponse`
    func requestDownload(for request: URLRequestConvertible) async throws -> NetworkDownloadResponse
    
    /// Descarga el contenido de una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `URL` con la ruta del contenido descargado y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    func requestDownload(for str: String, delegate: URLSessionTaskDelegate?) async throws -> NetworkDownloadResponse
    
    /// Descarga el contenido de una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    /// - Returns: Respuesta del servidor que contiene `URL` con la ruta del contenido descargado y `URLResponse`
    func requestDownload(for str: String) async throws -> NetworkDownloadResponse
    
    // Realiza la subida de contenido a un `URLRequestConvertible`. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la subida del contenido
    ///   - bodyData: `Data` que debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    func requestUpload(for request: URLRequestConvertible, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> NetworkUploadResponse
    
    /// Realiza la subida de contenido a un `URLRequestConvertible`. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la subida del contenido
    ///   - bodyData: `Data` que debe enviar al servidor
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    func requestUpload(for request: URLRequestConvertible, from bodyData: Data) async throws -> NetworkUploadResponse
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - bodyData: `Data` que debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    func requestUpload(for str: String, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> NetworkUploadResponse
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - bodyData: `Data` que debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    func requestUpload(for str: String, from bodyData: Data) async throws -> NetworkUploadResponse
    
    /// Realiza la subida de contenido a un `URLRequestConvertible`. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la subida del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    func requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> NetworkUploadResponse
    
    /// Realiza la subida de contenido a un `URLRequestConvertible`. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la subida del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    func requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL) async throws -> NetworkUploadResponse
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    func requestUpload(for str: String, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> NetworkUploadResponse
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    func requestUpload(for str: String, fromFile fileURL: URL) async throws -> NetworkUploadResponse
}

extension NetworkSession {
    public func requestStart(networkSession: NetworkSession, originalRequest: URLRequest) {
#if DEBUG
        print("[NetworkSession] - Start Request: \(originalRequest.curl)")
#endif
    }
    
    public func interceptResponse(networkSession: NetworkSession, originalRequest: URLRequest, retryNumber: Int, result: Result<NetworkSessionInterception, Error>) async throws -> NetworkSessionInterceptionResult {
#if DEBUG
        switch result {
        case .success(.data(let response)):
            print("[NetworkSession] - Intercept Response: \(response.data)")
        case .success(.download(let response)):
            print("[NetworkSession] - Intercept Response: File downloaded at path \(response.url)")
        case .success(.upload(let response)):
            print("[NetworkSession] - Intercept Response: \(response.data)")
        case .failure(let error):
            print("[NetworkSession] - Intercept Response: \(error)")
        }
#endif
        return .nothing
    }
}

extension NetworkSession {
    @available(iOS 15, tvOS 15, *)
    public func requestData(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        return try await _requestData(for: request, delegate: delegate)
    }
    
    public func requestData(for request: URLRequestConvertible) async throws -> NetworkDataResponse {
        return try await _requestData(for: request, delegate: nil)
    }
    
    @available(iOS 15, tvOS 15, *)
    public func requestData(for str: String, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestData(for: url, delegate: delegate)
    }
    
    public func requestData(for str: String) async throws -> NetworkDataResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestData(for: url)
    }
    
    private func _requestData(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?, retryNumber: Int = 0) async throws -> NetworkDataResponse {
        let originalRequest = request.asURLRequest()
        let urlRequest = request.asURLRequest()
        requestStart(networkSession: self, originalRequest: urlRequest)
        do {
            let response: NetworkDataResponse
            if #available(iOS 15, tvOS 15, *) {
                response = try await NetworkDataResponse(dataResponse: session.data(for: urlRequest, delegate: delegate), originalRequest: originalRequest)
            } else {
                response = try await withCheckedThrowingContinuation { continuation in
                    let dataTask = session.dataTask(with: urlRequest) { data, response, error in
                        do {
                            try Task.checkCancellation()
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let data = data, let response = response {
                                continuation.resume(returning: NetworkDataResponse(dataResponse: (data, response), originalRequest: originalRequest))
                            } else {
                                continuation.resume(throwing: NetworkError.unknown)
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                    dataTask.resume()
                }
            }
            return try await _handleResponseDataInterpection(result: .success(response), request: originalRequest, delegate: delegate, retryNumber: retryNumber)
        } catch {
            return try await _handleResponseDataInterpection(result: .failure(error), request: originalRequest, delegate: delegate, retryNumber: retryNumber)
        }
    }
    
    private func _handleResponseDataInterpection(result: Result<NetworkDataResponse, Error>, request: URLRequestConvertible, delegate: URLSessionTaskDelegate?, retryNumber: Int) async throws -> NetworkDataResponse {
        
        switch result {
        case .success(let response):
            let interception = try await interceptResponse(networkSession: self, originalRequest: request.asURLRequest(), retryNumber: retryNumber, result: .success(.data(response)))
            switch interception {
            case .nothing:
                return response
            case .retry(let newRequest):
                return try await _requestData(for: newRequest, delegate: delegate, retryNumber: retryNumber + 1)
            }
        case .failure(let error):
            let interception = try await interceptResponse(networkSession: self, originalRequest: request.asURLRequest(), retryNumber: retryNumber, result: .failure(error))
            switch interception {
            case .nothing:
                throw error
            case .retry(let newRequest):
                return try await _requestData(for: newRequest, delegate: delegate, retryNumber: retryNumber + 1)
            }
        }
    }
}

extension NetworkSession {
    @available(iOS 15, tvOS 15, *)
    public func requestDownload(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?) async throws -> NetworkDownloadResponse {
        return try await _requestDownload(for: request, delegate: delegate)
    }
    
    public func requestDownload(for request: URLRequestConvertible) async throws -> NetworkDownloadResponse {
        return try await _requestDownload(for: request, delegate: nil)
    }
    
    @available(iOS 15, tvOS 15, *)
    public func requestDownload(for str: String, delegate: URLSessionTaskDelegate?) async throws -> NetworkDownloadResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestDownload(for: url, delegate: delegate)
    }
    
    public func requestDownload(for str: String) async throws -> NetworkDownloadResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestDownload(for: url)
    }
    
    private func _requestDownload(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?, retryNumber: Int = 0) async throws -> NetworkDownloadResponse {
        let originalRequest = request.asURLRequest()
        let urlRequest = request.asURLRequest()
        requestStart(networkSession: self, originalRequest: urlRequest)
        do {
            let response: NetworkDownloadResponse
            if #available(iOS 15, tvOS 15, *) {
                response = try await NetworkDownloadResponse(dataResponse: session.download(for: urlRequest, delegate: delegate), originalRequest: originalRequest)
            } else {
                response = try await withCheckedThrowingContinuation { continuation in
                    let dataTask = session.downloadTask(with: urlRequest) { url, response, error in
                        do {
                            try Task.checkCancellation()
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let url = url, let response = response {
                                continuation.resume(returning: NetworkDownloadResponse(dataResponse: (url, response), originalRequest: originalRequest))
                            } else {
                                continuation.resume(throwing: NetworkError.unknown)
                            }
                            
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                    dataTask.resume()
                }
            }
            return try await _handleResponseDownloadInterpection(result: .success(response), request: originalRequest, delegate: delegate, retryNumber: retryNumber)
        } catch {
            return try await _handleResponseDownloadInterpection(result: .failure(error), request: originalRequest, delegate: delegate, retryNumber: retryNumber)
        }
    }
    
    private func _handleResponseDownloadInterpection(result: Result<NetworkDownloadResponse, Error>, request: URLRequestConvertible, delegate: URLSessionTaskDelegate?, retryNumber: Int) async throws -> NetworkDownloadResponse {
        
        switch result {
        case .success(let response):
            let interception = try await interceptResponse(networkSession: self, originalRequest: request.asURLRequest(), retryNumber: retryNumber, result: .success(.download(response)))
            switch interception {
            case .nothing:
                return response
            case .retry(let newRequest):
                return try await _requestDownload(for: newRequest, delegate: delegate, retryNumber: retryNumber + 1)
            }
        case .failure(let error):
            let interception = try await interceptResponse(networkSession: self, originalRequest: request.asURLRequest(), retryNumber: retryNumber, result: .failure(error))
            switch interception {
            case .nothing:
                throw error
            case .retry(let newRequest):
                return try await _requestDownload(for: newRequest, delegate: delegate, retryNumber: retryNumber + 1)
            }
        }
    }
}

extension NetworkSession {
    @available(iOS 15, tvOS 15, *)
    public func requestUpload(for request: URLRequestConvertible, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> NetworkUploadResponse {
        return try await _requestUpload(for: request, from: bodyData, delegate: delegate)
    }
    
    public func requestUpload(for request: URLRequestConvertible, from bodyData: Data) async throws -> NetworkUploadResponse {
        return try await _requestUpload(for: request, from: bodyData, delegate: nil)
    }
    
    @available(iOS 15, tvOS 15, *)
    public func requestUpload(for str: String, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> NetworkUploadResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestUpload(for: url, from: bodyData, delegate: delegate)
    }
    
    public func requestUpload(for str: String, from bodyData: Data) async throws -> NetworkUploadResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestUpload(for: url, from: bodyData)
    }
    
    private func _requestUpload(for request: URLRequestConvertible, from bodyData: Data, delegate: URLSessionTaskDelegate?, retryNumber: Int = 0) async throws -> NetworkUploadResponse {
        let originalRequest = request.asURLRequest()
        let urlRequest = request.asURLRequest()
        requestStart(networkSession: self, originalRequest: urlRequest)
        do {
            let response: NetworkUploadResponse
            if #available(iOS 15, tvOS 15, *) {
                response = try await NetworkUploadResponse(dataResponse: session.upload(for: urlRequest, from: bodyData, delegate: delegate), originalRequest: originalRequest, uploadType: .data(bodyData))
            } else {
                response = try await withCheckedThrowingContinuation { continuation in
                    let dataTask = session.uploadTask(with: urlRequest, from: bodyData) { data, response, error in
                        do {
                            try Task.checkCancellation()
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let data = data, let response = response {
                                continuation.resume(returning: NetworkUploadResponse(dataResponse: (data, response), originalRequest: originalRequest, uploadType: .data(bodyData)))
                            } else {
                                continuation.resume(throwing: NetworkError.unknown)
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                    dataTask.resume()
                }
            }
            return try await _handleResponseUploadInterpection(result: .success(response), request: originalRequest, from: bodyData, delegate: delegate, retryNumber: retryNumber)
        } catch {
            return try await _handleResponseUploadInterpection(result: .failure(error), request: originalRequest, from: bodyData, delegate: delegate, retryNumber: retryNumber)
        }
    }
    
    private func _handleResponseUploadInterpection(result: Result<NetworkUploadResponse, Error>, request: URLRequestConvertible, from bodyData: Data, delegate: URLSessionTaskDelegate?, retryNumber: Int) async throws -> NetworkUploadResponse {
        
        switch result {
        case .success(let response):
            let interception = try await interceptResponse(networkSession: self, originalRequest: request.asURLRequest(), retryNumber: retryNumber, result: .success(.upload(response)))
            switch interception {
            case .nothing:
                return response
            case .retry(let newRequest):
                return try await _requestUpload(for: newRequest, from: bodyData, delegate: delegate, retryNumber: retryNumber + 1)
            }
        case .failure(let error):
            let interception = try await interceptResponse(networkSession: self, originalRequest: request.asURLRequest(), retryNumber: retryNumber, result: .failure(error))
            switch interception {
            case .nothing:
                throw error
            case .retry(let newRequest):
                return try await _requestUpload(for: newRequest, from: bodyData, delegate: delegate, retryNumber: retryNumber + 1)
            }
        }
    }
}

extension NetworkSession {
    @available(iOS 15, tvOS 15, *)
    public func requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> NetworkUploadResponse {
        return try await _requestUpload(for: request, fromFile: fileURL, delegate: delegate)
    }
    
    public func requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL) async throws -> NetworkUploadResponse {
        return try await _requestUpload(for: request, fromFile: fileURL, delegate: nil)
    }
    
    @available(iOS 15, tvOS 15, *)
    public func requestUpload(for str: String, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> NetworkUploadResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestUpload(for: url, fromFile: fileURL, delegate: delegate)
    }
    
    public func requestUpload(for str: String, fromFile fileURL: URL) async throws -> NetworkUploadResponse {
        guard let url = URL(string: str) else { throw NetworkError.request(.invalidURL)}
        return try await requestUpload(for: url, fromFile: fileURL)
    }
    
    private func _requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?, retryNumber: Int = 0) async throws -> NetworkUploadResponse {
        let originalRequest = request.asURLRequest()
        let urlRequest = request.asURLRequest()
        requestStart(networkSession: self, originalRequest: urlRequest)
        do {
            let response: NetworkUploadResponse
            if #available(iOS 15, tvOS 15, *) {
                response = try await NetworkUploadResponse(dataResponse: session.upload(for: urlRequest, fromFile: fileURL, delegate: delegate), originalRequest: originalRequest, uploadType: .file(fileURL))
            } else {
                response = try await withCheckedThrowingContinuation { continuation in
                    let dataTask = session.uploadTask(with: urlRequest, fromFile: fileURL) { data, response, error in
                        do {
                            try Task.checkCancellation()
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let data = data, let response = response {
                                continuation.resume(returning: NetworkUploadResponse(dataResponse: (data, response), originalRequest: originalRequest, uploadType: .file(fileURL)))
                            } else {
                                continuation.resume(throwing: NetworkError.unknown)
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                    dataTask.resume()
                }
            }
            return try await _handleResponseUploadInterpection(result: .success(response), request: originalRequest, fromFile: fileURL, delegate: delegate, retryNumber: retryNumber)
        } catch {
            return try await _handleResponseUploadInterpection(result: .failure(error), request: originalRequest, fromFile: fileURL, delegate: delegate, retryNumber: retryNumber)
        }
    }
    
    private func _handleResponseUploadInterpection(result: Result<NetworkUploadResponse, Error>, request: URLRequestConvertible, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?, retryNumber: Int) async throws -> NetworkUploadResponse {
        
        switch result {
        case .success(let response):
            let interception = try await interceptResponse(networkSession: self, originalRequest: request.asURLRequest(), retryNumber: retryNumber, result: .success(.upload(response)))
            switch interception {
            case .nothing:
                return response
            case .retry(let newRequest):
                return try await _requestUpload(for: newRequest, fromFile: fileURL, delegate: delegate, retryNumber: retryNumber + 1)
            }
        case .failure(let error):
            let interception = try await interceptResponse(networkSession: self, originalRequest: request.asURLRequest(), retryNumber: retryNumber, result: .failure(error))
            switch interception {
            case .nothing:
                throw error
            case .retry(let newRequest):
                return try await _requestUpload(for: newRequest, fromFile: fileURL, delegate: delegate, retryNumber: retryNumber + 1)
            }
        }
    }
}
