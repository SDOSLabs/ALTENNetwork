- [ALTENNetwork](#altennetwork)
  - [Introducción](#introducción)
  - [Instalación](#instalación)
    - [Añadir al proyecto](#añadir-al-proyecto)
    - [Como dependencia en Package.swift](#como-dependencia-en-packageswift)
  - [Cómo se usa](#cómo-se-usa)
    - [Hacer una petición](#hacer-una-petición)
    - [Interceptar respuesta de una petición](#interceptar-respuesta-de-una-petición)
    - [Crear un `NetworkRequest`](#crear-un-networkrequest)
    - [`NetworkDataResponse`, `NetworkDownloadResponse` y `NetworkUploadResponse`](#networkdataresponse-networkdownloadresponse-y-networkuploadresponse)
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
    .package(url: "https://github.com/SDOSLabs/ALTENNetwork.git", .upToNextMajor(from: "4.0.0"))
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

La librería usa el protocolo `NetworkSession` como core de su funcionalidad, que proporciona soporte para realizar llamadas a internet con `Async/Await` desde `iOS/tvOS 13` en adelante.
Para usar la librería hay que crear una clase que implemente el protocolo `NetworkSession`. Por defecto, sólo es necesario pasarle la `URLSession` que se usará para hacer las llamadas a servicios.

``` swift
final class AppURLSession: NetworkSession {
    var session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
}
````

Todos los demás métodos del protocolo están implementados y no es necesario hacer nada más para usarla, pero se pueden sobrescribir si fuera necesario.

A partir de aquí, sólo será necesario crear un objeto del tipo `AppURLSession` para hacer las llamadas a servicios.

``` swift
let networkSession: NetworkSession = AppURLSession(session: URLSession(configuration: configuration, delegate: nil, delegateQueue: nil))

func doRequest() async throws -> Data {
    let url = "https://alten.es"
    let result = try await networkSession.requestData(for: url)
    return result.data
}
````

La definición del protocolo `NetworkSession` es la siguiente:


``` swift 
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
    
    /// Este método se llamará antes de que comience cualquier request. Tiene como parámetro de entrada la URLRequest a la que se está llamando. Este método tiene como objetivo modificar la Request antes de que se realice la petición.
    /// La implementación por defecto imprime el curl de la request sólo en entornos de debug a través de la condificón `#if DEBUG`
    /// - Parameters:
    /// - networkSession: `NetworkSession` que realiza la petición
    /// - originalRequest: `URLRequest` original a la que se está llamando
    /// - Returns: `URLRequest` que se debe realizar
    func interceptRequest(networkSession: NetworkSession, originalRequest: URLRequest) async -> URLRequestConvertible
    
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
```

### Hacer una petición

Para usar cualquiera de estas funciones hace falta invocarla desde un contexto asíncrono:

``` swift 
let networkSession: NetworkSession = AppURLSession(session: URLSession(configuration: configuration, delegate: nil, delegateQueue: nil))

func doRequest() async throws -> Data {
    let url = "https://alten.es"
    let result = try await networkSession.requestData(for: url)
    return result.data
}
```
---

### Interceptar request de una petición

Pordemos usar la función `interceptRequest` para interceptar la petición antes de realizarla y modificarla. Por ejemplo, podemos usarlo para añadir cabeceras a la petición.

``` swift 
extension AppURLSession {
    func requestStart(networkSession: NetworkSession, originalRequest: URLRequest) {
        var request = originalRequest
        request.addValue("Token", forHTTPHeaderField: "Authorization")
        return request
    }
}
``` 

También podemos usar esta función para imprimir por consola la respuesta de la petición.

``` swift
extension AppURLSession {
    func requestStart(networkSession: NetworkSession, originalRequest: URLRequest) {
        #if DEBUG
        print("[NetworkSession] - Start Request: \(originalRequest.curl)")
        #endif
        return originalRequest  
    }
}
```

### Interceptar respuesta de una petición

Podemos usar la función `interceptResponse` para interceptar la respuesta antes de continuar con el flujo y detectar posibles errores o respuestas que debemos manejar de forma genérica. 
Por ejemplo, podemos usarlo para refrescar un token cuando la respuesta es un código de error 401.

``` swift
extension AppURLSession {
    func interceptResponse(networkSession: NetworkSession, originalRequest: URLRequest, retryNumber: Int, result: Result<NetworkSessionInterception, Error>) async throws -> NetworkSessionInterceptionResult {
        guard retryNumber < 1 else { return .nothing }
        
        var httpURLRespone: HTTPURLResponse? = nil
        switch result {
        case .success(.data(let dataResponse)):
            if let _httpURLRespone = dataResponse.response as? HTTPURLResponse {
                httpURLRespone = _httpURLRespone
            }
        case .success(.download(let dataResponse)):
            if let _httpURLRespone = dataResponse.response as? HTTPURLResponse {
                httpURLRespone = _httpURLRespone
            }
        case .success(.upload(let dataResponse)):
            if let _httpURLRespone = dataResponse.response as? HTTPURLResponse {
                httpURLRespone = _httpURLRespone
            }
        case .failure(let error):
            throw error
        }
        if let httpURLRespone, httpURLRespone.statusCode == 401 {
            let newRequest = try await refreshToken() // Implement refresh and return a new request with others authentication headers
            return .retry(newRequest)
        }
        return .nothing
    }
}
``` 

También podemos usar esta función para imprimir por consola la respuesta de la petición.

``` swift
extension AppURLSession {
    func interceptResponse(networkSession: NetworkSession, originalRequest: URLRequest, retryNumber: Int, result: Result<NetworkSessionInterception, Error>) async throws -> NetworkSessionInterceptionResult {
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
```

---

### Crear un `NetworkRequest`

También proporciona la clase `NetworkRequest` como forma sencilla de crear peticiones con los parámetros más comunes:

``` swift
let networkSession: NetworkSession = AppURLSession(session: URLSession(configuration: configuration, delegate: nil, delegateQueue: nil))

func getFilms(searchText: String, page: Int) async throws -> Data {
    let networkRequest = try NetworkRequest(url: "https://www.omdbapi.com/", query: [
        .query(key: "apikey", value: "xxxxxxxx"),
        .query(key: "page", value: "\(page)"),
        .query(key: "s", value: searchText)
    ])
    
    let result = try await networkSession.requestData(for: networkRequest)
    return result.data
}
```

La clase `NetworkRequest` tiene varios inicializadores y permiten las configuraciones más comunes que suelen tener un `URLRequest`. Internamente la clase `NetworkRequest` implementa el protocolo `URLRequestConvertible`, que es el requisito para poder transformarlo en un `URLRequest`.

Los parámetros de la query se pueden pasar como un tipo `NetworkQuery`. El valor de estos parámetros no debe estar codificado para el envio en la url. La propia librería se encarga de codificarlo.

La clase `NetworkRequest` es extensible y se puede heredar para complementarlo en base a las necesidades del proyecto.

También es posible crearse un componente totalmente personalizado que implemente el protocolo `URLRequestConvertible` para poder usarlo en las peticiones.

#### Soporte JSON

La librería permite enviar parámetros en json fácilmente. Para ello debemos tener una estructura de datos que implemente el protocolo `Encodable` y pasarselo en el parámetro `jsonBody`. Esto hará que el body de la petición sea el json de dicha estructura.

``` swift
let networkSession: NetworkSession = AppURLSession(session: URLSession(configuration: configuration, delegate: nil, delegateQueue: nil))

func getFilms(searchText: String, page: Int) async throws -> Data {
    let networkRequest = try NetworkRequest(
        url: "https://www.omdbapi.com/",
        httpMethod: .post,
        headers: nil,
        query: nil,
        jsonBody: FilmRequestDTO(apiKey: "xxxxxxxx", s: searchText, page: page),
        encoder: JSONEncoder())
    
    let result = try await networkSession.requestData(for: networkRequest)
    return result.data
}
```

Al utilizar estas funciones se incluye automáticamente la cabecera `Content-Type: application/json` a la request.

#### Soporte Multipart Form

La clase `NetworkRequest` puede crear request para soportar llamadas de tipo `multipart/form-data`. Estas peticiones tienen una estructura del body específica y la librería permite crearla fácilmente usando el parámetro `multipartForm` del inicializador.

``` swift
let networkSession: NetworkSession = AppURLSession(session: URLSession(configuration: configuration, delegate: nil, delegateQueue: nil))

func uploadImage(image: Data) async throws -> Data {
    let networkRequest = try NetworkRequest(
        url: "https://endpoint.com/upload/image",
        httpMethod: .post,
        headers: nil,
        query: nil,
        multipartForm: NetworkMultipartFormFileRequest(name: "image", filename: "profile.png", value: image, contentType: "application/png"))
    
    let result = try await networkSession.requestUpload(for: networkRequest)
    return result.data
}
```

El parámetro `multipartForm` recibe un array de `NetworkMultipartFormDataConvertible`. La librería tiene 3 estructuras que implementan este protocolo:
- `NetworkMultipartFormJsonRequest`: Se usa cuando se quiera enviar un json
- `NetworkMultipartFormFileRequest`: Se usa cuando se queira enviar un fichero
- `NetworkMultipartFormDataRequest`: Se usa cuando se quiera enviar un tipo de dato no contemplado en los otros casos

Esa implementación puede ser extendida creando nuestra propia implementación del protocolo `NetworkMultipartFormDataConvertible`.


---

### `NetworkDataResponse`, `NetworkDownloadResponse` y `NetworkUploadResponse`

La librería también encapsula la respuesta de las peticiones en un objeto `NetworkDataResponse`, `NetworkDownloadResponse` o `NetworkUploadResponse` (dependiendo del método de petición utilizado) para facilitar el tratamiento de los datos.

Sobre estos objetos existen algunas funciones útiles de validación de la petición y codificación de los datos desde `json` que serán muy útiles para cualquier proyecto:

``` swift
let networkSession: NetworkSession = AppURLSession(session: URLSession(configuration: configuration, delegate: nil, delegateQueue: nil))

func getFilms(searchText: String, page: Int) async throws -> FilmsSearchDTO<[FilmDTO]> {
    let networkRequest = try NetworkRequest(url: "https://www.omdbapi.com/", query: [
        .query(key: "apikey", value: "xxxxxxxx"),
        .query(key: "page", value: "\(page)"),
        .query(key: "s", value: searchText)
    ])
    
    let result = try await networkSession.requestData(for: networkRequest).validate().jsonDecode(FilmsSearchDTO<[FilmDTO]>.self)
    return result
}
```

También se pueden crear extensiones de `NetworkDataResponse`, `NetworkDownloadResponse` y `NetworkUploadResponse` para crear funciones de utilidades como por ejemplo para mostrar por consola la respuesta recibida o validar la petición de forma diferente:

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

