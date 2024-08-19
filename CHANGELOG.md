## [4.0.0](https://github.com/SDOSLabs/ALTENNetwork/tree/4.0.0)
- Change protocol `NetworkSession`. Now it's not recommended extend `URLSession` with `NetworkSession`. Instead create your own class and implement `NetworkSession`.

``` swift
final class AppURLSession: NetworkSession {
    var session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
}
````

With this class you can call any web services:

``` swift
let networkSession: NetworkSession = AppURLSession(session: URLSession(configuration: configuration, delegate: nil, delegateQueue: nil))

func doRequest() async throws -> Data {
    let url = "https://alten.es"
    let result = try await networkSession.requestData(for: url)
    return result.data
}
````

- Add new function `interceptResponse` in `NetworkSession` protocol. This function allows to intercept the response before continue the process in the library. You can use this function for example to refresh the token when the response is 401.

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

## [3.0.1](https://github.com/SDOSLabs/ALTENNetwork/tree/3.0.1)
- Incluido fichero `PrivacyInfo.xcprivacy` requerido por Apple: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api

## [3.0.0](https://github.com/SDOSLabs/ALTENNetwork/tree/3.0.0)

- Remove `URLSession` extension. Create protocol `NetworkSession` with all the implementation. You need conformace protocol `NetworkSession` for `URLSession` in your app
``` swift
extension URLSession: NetworkSession { }
```

You can override the new function `requestStart(originalRequest: URLRequest)` for debug purposes
``` swift 
extension URLSession: NetworkSession {
    public func requestStart(originalRequest: URLRequest) {
        #if DEBUG
        print(originalRequest.curl)
        #endif
    }
}
``` 

## [2.2.0](https://github.com/SDOSLabs/ALTENNetwork/tree/2.2.0)

- Add parameter `originalRequest` to `NetworkDataResponse` and `NetworkDownloadResponse`
 
## [2.1.0](https://github.com/SDOSLabs/ALTENNetwork/tree/2.1.0)

- Add `forceEncodingPlusSymbol` for `NetworkQuery`. Allows to encoding value `+` to `%2B`

## [2.0.0](https://github.com/SDOSLabs/ALTENNetwork/tree/2.0.0)

- Remove `allowEncodingValue` for `NetworkQuery`. Now the `value` of `NetworkQuery` always is encoded by the library.

## [1.1.0](https://github.com/SDOSLabs/ALTENNetwork/tree/1.1.0)

- Added control available for tvOS

## [1.0.0](https://github.com/SDOSLabs/ALTENNetwork/tree/1.0.0)

- Create first stable version
