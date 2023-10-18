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
