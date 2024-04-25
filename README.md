- [ALTENNetwork](#altennetwork)
  - [Introducción](#introducción)
  - [Instalación](#instalación)
    - [Añadir al proyecto](#añadir-al-proyecto)
    - [Como dependencia en Package.swift](#como-dependencia-en-packageswift)
  - [Cómo se usa](#cómo-se-usa)
    - [Hacer una petición](#hacer-una-petición)
    - [Crear un `NetworkRequest`](#crear-un-networkrequest)
    - [`NetworkDataResponse` y `NetworkDownloadResponse`](#networkdataresponse-y-networkdownloadresponse)
    - [Control de conexión con `NetworkReachability`](#control-de-conexión-con-networkreachability)

# ALTENNetwork
- Changelog: https://github.com/SDOSLabs/ALTENNetwork/blob/main/CHANGELOG.md

## Introducción
`ALTENNetwork` es una librería creada con el fin de facilitar la creación y la llamada de peticiones con `URLSession`. Añade la capacidad de usar `Async/Await` a `URLSession` desde `iOS/tvOS 13` y proporciona un el objeto `NetworkRequest` que facilita la creación de un `URLRequest` con los parámetros más comunes.

## Instalación

### Añadir al proyecto

Abrir Xcode y e ir al apartado `File > Add Packages...`. En el cuadro de búsqueda introducir la url del respositorio y seleccionar la versión:
```
https://github.com/SDOSLabs/ALTENNetwork.git
```

### Como dependencia en Package.swift

``` swift
dependencies: [
    .package(url: "https://github.com/SDOSLabs/ALTENNetwork.git", .upToNextMajor(from: "3.0.1"))
]
```

Se debe añadir al target de la aplicación en la que queremos que esté disponible

``` swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "ALTENNetwork", package: "ALTENNetwork")
    ]),
```

## Cómo se usa

La librería proporciona el protocolo `NetworkSession` que añade soporte para `Async/Await` desde `iOS/tvOS 13` en adelante. 
El único requisito para su uso es hacer que `URLSession` implemente el protocolo `NetworkSession`.

``` swift 
extension URLSession: NetworkSession { }
``` 

> Truco: La función `requestStart(originalRequest: URLRequest)` de `NetworkSession` existe por motivos de depuración. Al imprimir por consola datos de la request original podemos exponer datos sensibles, por lo que se recomienda usar un logger o una condición para mostrar esta información sólo en debug.

``` swift 
extension URLSession: NetworkSession {
    public func requestStart(originalRequest: URLRequest) {
        #if DEBUG
        print(originalRequest.curl)
        #endif
    }
}
``` 

La definición del protocolo `NetworkSession` es la siguiente:


``` swift 
/// Contiene todos los métodos disponibles para realizar llamadas con async/await
public protocol NetworkSession: URLSession {
    
    /// Este método se llamará antes de que comience cualquier request. Tiene como parámetro de entrada la URLRequest a la que se está llamando y su único objetivo es que sirva de caracter informativo
    /// - Parameter originalRequest: request original a la que se llamará
    func requestStart(originalRequest: URLRequest)
    
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
    func requestUpload(for request: URLRequestConvertible, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse
    
    /// Realiza la subida de contenido a un `URLRequestConvertible`. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la subida del contenido
    ///   - bodyData: `Data` que debe enviar al servidor
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    func requestUpload(for request: URLRequestConvertible, from bodyData: Data) async throws -> NetworkDataResponse
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - bodyData: `Data` que debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    func requestUpload(for str: String, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - bodyData: `Data` que debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    func requestUpload(for str: String, from bodyData: Data) async throws -> NetworkDataResponse
    
    /// Realiza la subida de contenido a un `URLRequestConvertible`. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la subida del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    func requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse
    
    /// Realiza la subida de contenido a un `URLRequestConvertible`. `URLRequestConvertible` es en esencia un `URLRequest`. De forma básica podemos usar un `URL` o un `URLRequest` para realizar la petición
    /// - Parameters:
    ///   - request: `URLRequestConvertible` que se debe llamar para la subida del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    func requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL) async throws -> NetworkDataResponse
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    ///   - delegate: Delegado que recibe los eventos del ciclo de vida de la petición
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    @available(iOS 15, tvOS 15, *)
    func requestUpload(for str: String, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse
    
    /// Realiza la subida de contenido a una `URL` dado en formato `String`
    /// - Parameters:
    ///   - str: `String` que se debe llamar para la descarga del contenido
    ///   - fromFile: `URL` del fichero que se debe enviar al servidor
    /// - Returns: Respuesta del servidor que contiene `Data` y `URLResponse`
    func requestUpload(for str: String, fromFile fileURL: URL) async throws -> NetworkDataResponse
}
```

### Hacer una petición

Para usar cualquiera de estas funciones hace falta invocarla desde un contexto asíncrono:

``` swift 
func doRequest() async throws -> Data {
    let url = "https://alten.es"
    let result = try await session.requestData(for: url)
    return result.data
}
```
---

### Crear un `NetworkRequest`

También proporciona la clase `NetworkRequest` como forma sencilla de crear peticiones con los parámetros más comunes:

``` swift
func getFilms(searchText: String, page: Int) async throws -> Data {
    let networkRequest = try NetworkRequest(url: "https://www.omdbapi.com/", query: [
        .query(key: "apikey", value: "xxxxxxxx"),
        .query(key: "page", value: "\(page)"),
        .query(key: "s", value: searchText)
    ])
    
    let result = try await session.requestData(for: networkRequest)
    return result.data
}
```

La clase `NetworkRequest` tiene varios inicializadores y permiten las configuraciones más comunes que suelen tener un `URLRequest`. Internamente la clase `NetworkRequest` implementa el protocolo `URLRequestConvertible`, que es el requisito para poder transformarlo en un `URLRequest`.

Los parámetros de la query se pueden pasar como un tipo `NetworkQuery`. El valor de estos parámetros no debe estar codificado para el envio en la url. La propia librería se encarga de codificarlo

Más ejemplos:

``` swift
func getFilms(searchText: String, page: Int) async throws -> Data {
    let networkRequest = try NetworkRequest(
        url: "https://www.omdbapi.com/",
        httpMethod: .post,
        headers: nil,
        query: nil,
        jsonBody: FilmRequestDTO(apiKey: "xxxxxxxx", s: searchText, page: page),
        encoder: JSONEncoder())
    
    let result = try await session.requestData(for: networkRequest)
    return result.data
}
```

La clase `NetworkRequest` es extensible y se puede heredar para complementarlo en base a las necesidades del proyecto.

También es posible crearse un componente totalmente personalizado que implemente el protocolo `URLRequestConvertible` para poder usarlo en las peticiones.

---

### `NetworkDataResponse` y `NetworkDownloadResponse`

La librería también encapsula la respuesta de las peticiones en un objeto `NetworkDataResponse` o `NetworkDownloadResponse` (dependiendo del método de petición utilizado) para facilitar el tratamiento de los datos.

Sobre estos objetos existen algunas funciones útiles de validación de la petición y codificación de los datos desde `json` que serán muy útiles para cualquier proyecto:

``` swift
func getFilms(searchText: String, page: Int) async throws -> FilmsSearchDTO<[FilmDTO]> {
    let networkRequest = try NetworkRequest(url: "https://www.omdbapi.com/", query: [
        .query(key: "apikey", value: "xxxxxxxx"),
        .query(key: "page", value: "\(page)"),
        .query(key: "s", value: searchText)
    ])
    
    let result = try await session.requestData(for: networkRequest).validate().jsonDecode(FilmsSearchDTO<[FilmDTO]>.self)
    return result
}
```

También se pueden crear extensiones de `NetworkDataResponse` y `NetworkDownloadResponse` para crear funciones de utilidades como por ejemplo para mostrar por consola la respuesta recibida o validar la petición de forma diferente:

``` swift
extension NetworkDataResponse {
    public func logResponse() -> Self {
        if let text = String(data: data, encoding: .utf8) {
            print("[NetworkDataResponse] String: \(text)")
        } else {
            print("[NetworkDataResponse] Data recieved is not a String: \(data.count) bytes")
        }
        return self
    }
}

extension NetworkDataResponse {
    public func validateApi(correctRange range: HTTPCodes = .success) throws -> Self {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.responseData(.invalidResponse(self))
        }
        let range: HTTPCodes = .success
        guard range ~= response.statusCode else {
            if 400..<500 ~= response.statusCode {
                if response.statusCode == 401 {
                    throw ErrorApp.networkUnauthorized
                } else {
                    if let object = try? JSONDecoder().decode(AppErrorDTO.self, from: data) {
                        throw <#T##Your Error#>
                    } else {
                        throw NetworkError.responseData(.invalidStatusCode(self, response.statusCode))
                    }
                }
            } else {
                throw NetworkError.responseData(.invalidStatusCode(self, response.statusCode))
            }
        }
        return try validate(correctRange: range)
    }
}
```

---

### Control de conexión con `NetworkReachability`

La clase `NetworkReachability` permite la suscripción a un `AsyncThrowingStream<NetworkReachability, Error>` que notificará de los cambios de red que se produzcan en el dispositivo.
 
 Ejemplo:
 
 En un contexto no asíncrono
 ``` swift
 func checkConnection() {
     if let reachability = try? NetworkReachability(), let notifier = try? reachability.startNotifier() {
         self.reachability = reachability // retain `reachability`
         Task {
             for try await reachability in notifier {
                 print("Connection type: \(reachability.connection.rawValue)")
             }
             print("Finish Reachability")
         }
     }
 }
 
 ```

 ---
 
 En un contexto asíncrono
 ``` swift
 func checkConnection() async throws {
     if let reachability = try? NetworkReachability(), let notifier = try? reachability.startNotifier() {
         self.reachability = reachability // retain `reachability`
         Task {
             for try await reachability in notifier {
                 print("Connection type: \(reachability.connection.rawValue)")
             }
             print("Finish Reachability")
         }
     }
 }
 ```
 
 ---
 
 La creación del objeto `try? NetworkReachability()` hay que retenerla en memoria para mantener la suscripción.
 
 La creación del objeto `let notifier = try? reachability.startNotifier()` se debe realizar en una nueva `Task`, ya que a la hora de realizar el `for-await-in` la `Task` se quedará en ejecución y no terminará hasta que finalizemos el loop manualmente o a través de la liberación de memoria.

