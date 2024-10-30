import XCTest
@testable import ALTENNetwork

final class ALTENNetworkTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(try? NetworkRequest(url: "https://google.es").asURLRequest().url?.absoluteString, "https://google.es")

        XCTAssertEqual(try? NetworkRequest(url: "https://google.es", query: [.query(key: "key", value: "value")]).asURLRequest().url?.absoluteString, "https://google.es?key=value")
        
        XCTAssertEqual(try? NetworkRequest(url: "https://google.es?prueba=valor", query: [.query(key: "key", value: "value")]).asURLRequest().url?.absoluteString, "https://google.es?prueba=valor&key=value")

        XCTAssertEqual(try? NetworkRequest(url: "https://google.es", query: [.query(key: "key", value: "value")]).asURLRequest().url?.absoluteString, "https://google.es?key=value")

        XCTAssertEqual(try? NetworkRequest(url: "https://google.es", query: [.query(key: "key", value: "!$&'()*+,;=")]).asURLRequest().url?.absoluteString, "https://google.es?key=!$%26\'()*+,;%3D")

        XCTAssertEqual(try? NetworkRequest(url: "https://google.es", query: [.query(key: "key", value: "!$&'()*+, ;=")]).asURLRequest().url?.absoluteString, "https://google.es?key=!$%26'()*+,%20;%3D")
        
        XCTAssertEqual(try? NetworkRequest(url: "https://google.es", query: [.query(key: "key", value: "!$&'()*+, ;=", forceEncodingPlusSymbol: true)]).asURLRequest().url?.absoluteString, "https://google.es?key=!$%26'()*%2B,%20;%3D")
        
        XCTAssertEqual(try? NetworkRequest(url: "https://google.es", query: [.query(key: "key", value: "!$&'()*+, ;=", forceEncodingPlusSymbol: true), .query(key: "key2", value: "!$&'()*+, ;=")]).asURLRequest().url?.absoluteString, "https://google.es?key=!$%26'()*%2B,%20;%3D&key2=!$%26'()*+,%20;%3D")
        
        XCTAssertEqual(try? NetworkRequest(url: "https://google.es?prueba=valor", query: [.query(key: "key", value: "!$&'()*+, ;=", forceEncodingPlusSymbol: true), .query(key: "key2", value: "!$&'()*+, ;=", forceEncodingPlusSymbol: false)]).asURLRequest().url?.absoluteString, "https://google.es?prueba=valor&key=!$%26'()*%2B,%20;%3D&key2=!$%26'()*+,%20;%3D")
    }
    
    func testMultipartFormData() throws {
        do {
            let text = "Hola probando texto"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormDataRequest(name: "clave", value: data)
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"clave\"\r\n".data(using: .utf8)
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let text = "Prueba de parámetro 2"
            let key = "id"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormDataRequest(name: key, value: data, additionalContentDispositionParameters: [NetworkMultipartFormParameter(key: "date", value: "2024-01-01")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"\(key)\"; date=\"2024-01-01\"\r\n".data(using: .utf8)
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let text = "Prueba 3"
            let key = "work"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormDataRequest(name: key, value: data, additionalContentDispositionParameters: [NetworkMultipartFormParameter(key: "date", value: "2024/01/01"), NetworkMultipartFormParameter(key: "email", value: "prueba@alten.es")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"\(key)\"; date=\"2024/01/01\"; email=\"prueba@alten.es\"\r\n".data(using: .utf8)
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let text = "Prueba 4"
            let key = "success"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormDataRequest(name: key, value: data, additionalHeaders: [NetworkMultipartFormHeader(key: "Content-Transfer-Encoding", value: "binary")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n".data(using: .utf8)
            expectedData?.append("Content-Transfer-Encoding: binary\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let text = "Prueba 5"
            let key = "identifier98"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormDataRequest(name: key, value: data, additionalHeaders: [NetworkMultipartFormHeader(key: "Content-Transfer-Encoding", value: "binary"), NetworkMultipartFormHeader(key: "Creation-Date", value: "1999-01-01")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n".data(using: .utf8)
            expectedData?.append("Content-Transfer-Encoding: binary\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("Creation-Date: 1999-01-01\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let text = "Prueba 6"
            let key = "title"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormDataRequest(
                name: key,
                value: data,
                additionalContentDispositionParameters: [NetworkMultipartFormParameter(key: "time", value: "22:24"), NetworkMultipartFormParameter(key: "updated", value: "true")],
                additionalHeaders: [NetworkMultipartFormHeader(key: "Content-Encoding", value: "base64"), NetworkMultipartFormHeader(key: "Creation", value: "2000-02-02")]
            )
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"\(key)\"; time=\"22:24\"; updated=\"true\"\r\n".data(using: .utf8)
            expectedData?.append("Content-Encoding: base64\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("Creation: 2000-02-02\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
    }
    
    func testMultipartFormFile() throws {
        do {
            let text = "Hola probando texto"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormFileRequest(name: "clave", filename: "archivo.txt", value: data, contentType: "text/plain")
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"clave\"; filename=\"archivo.txt\"\r\nContent-Type: text/plain\r\n".data(using: .utf8)
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let text = "Prueba de parámetro 2"
            let key = "id"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormFileRequest(name: key, filename: "archivo.txt", value: data, contentType: "text/plain", additionalContentDispositionParameters: [NetworkMultipartFormParameter(key: "date", value: "2024-01-01")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"\(key)\"; filename=\"archivo.txt\"; date=\"2024-01-01\"\r\nContent-Type: text/plain\r\n".data(using: .utf8)
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let text = "Prueba 3"
            let key = "work"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormFileRequest(name: key, filename: "archivo.png", value: data, contentType: "text/plain", additionalContentDispositionParameters: [NetworkMultipartFormParameter(key: "date", value: "2024/01/01"), NetworkMultipartFormParameter(key: "email", value: "prueba@alten.es")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"\(key)\"; filename=\"archivo.png\"; date=\"2024/01/01\"; email=\"prueba@alten.es\"\r\nContent-Type: text/plain\r\n".data(using: .utf8)
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let text = "Prueba 4"
            let key = "success"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormFileRequest(name: key, filename: "archivo.txt", value: data, contentType: "text/plain", additionalHeaders: [NetworkMultipartFormHeader(key: "Content-Transfer-Encoding", value: "binary")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"\(key)\"; filename=\"archivo.txt\"\r\nContent-Type: text/plain\r\n".data(using: .utf8)
            expectedData?.append("Content-Transfer-Encoding: binary\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let text = "Prueba 5"
            let key = "identifier98"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormFileRequest(name: key, filename: "archivo.txt", value: data, contentType: "text/plain", additionalHeaders: [NetworkMultipartFormHeader(key: "Content-Transfer-Encoding", value: "binary"), NetworkMultipartFormHeader(key: "Creation-Date", value: "1999-01-01")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"\(key)\"; filename=\"archivo.txt\"\r\nContent-Type: text/plain\r\n".data(using: .utf8)
            expectedData?.append("Content-Transfer-Encoding: binary\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("Creation-Date: 1999-01-01\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let text = "Prueba 6"
            let key = "title"
            let data = text.data(using: .utf8)!
            let request = NetworkMultipartFormFileRequest(
                name: key,
                filename: "archivo.txt",
                value: data,
                contentType: "text/plain",
                additionalContentDispositionParameters: [NetworkMultipartFormParameter(key: "time", value: "22:24"), NetworkMultipartFormParameter(key: "updated", value: "true")],
                additionalHeaders: [NetworkMultipartFormHeader(key: "Content-Encoding", value: "base64"), NetworkMultipartFormHeader(key: "Creation", value: "2000-02-02")]
            )
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"\(key)\"; filename=\"archivo.txt\"; time=\"22:24\"; updated=\"true\"\r\nContent-Type: text/plain\r\n".data(using: .utf8)
            expectedData?.append("Content-Encoding: base64\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("Creation: 2000-02-02\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(text.data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
    }
    
    func testMultipartFormJson() throws {
        do {
            let json = ["name": "Hola probando texto"]
            let jsonEncode = JSONEncoder(outputFormatting: .sortedKeys)
            let request = NetworkMultipartFormJsonRequest(name: "clave", value: json)
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"clave\"\r\n".data(using: .utf8)
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(try jsonEncode.encode(json))
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            struct Test: Encodable {
                let name: String
                let creationDate: String
            }
            let json = Test(name: "Prueba de parámetro 2", creationDate: "2024-01-01")
            let jsonEncode = JSONEncoder(outputFormatting: .sortedKeys)
            jsonEncode.keyEncodingStrategy = .convertToSnakeCase
            let request = NetworkMultipartFormJsonRequest(name: "clave", value: json, encoder: jsonEncode, additionalContentDispositionParameters: [NetworkMultipartFormParameter(key: "date", value: "2024-01-01")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"clave\"; date=\"2024-01-01\"\r\n".data(using: .utf8)
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(try jsonEncode.encode(json))
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let json = ["name": "Prueba 3", "creationDate": "2024/01/01", "email": "prueba@alten.es"]
            let jsonEncode = JSONEncoder(outputFormatting: .sortedKeys)
            let request = NetworkMultipartFormJsonRequest(name: "clave", value: json, additionalContentDispositionParameters: [NetworkMultipartFormParameter(key: "date", value: "2024/01/01"), NetworkMultipartFormParameter(key: "email", value: "prueba@alten.es")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"clave\"; date=\"2024/01/01\"; email=\"prueba@alten.es\"\r\n".data(using: .utf8)
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(try jsonEncode.encode(json))
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let json = ["name": "Prueba 4"]
            let jsonEncode = JSONEncoder(outputFormatting: .sortedKeys)
            let request = NetworkMultipartFormJsonRequest(name: "clave", value: json, additionalHeaders: [NetworkMultipartFormHeader(key: "Content-Transfer-Encoding", value: "binary")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"clave\"\r\n".data(using: .utf8)
            expectedData?.append("Content-Transfer-Encoding: binary\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(try jsonEncode.encode(json))
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let json = ["name": "Prueba 5"]
            let jsonEncode = JSONEncoder(outputFormatting: .sortedKeys)
            let request = NetworkMultipartFormJsonRequest(name: "clave", value: json, additionalHeaders: [NetworkMultipartFormHeader(key: "Content-Transfer-Encoding", value: "binary"), NetworkMultipartFormHeader(key: "Creation-Date", value: "1999-01-01")])
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"clave\"\r\n".data(using: .utf8)
            expectedData?.append("Content-Transfer-Encoding: binary\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("Creation-Date: 1999-01-01\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(try jsonEncode.encode(json))
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
        
        do {
            let json = ["name": "Prueba 6"]
            let jsonEncode = JSONEncoder(outputFormatting: .sortedKeys)
            let request = NetworkMultipartFormJsonRequest(
                name: "clave",
                value: json,
                additionalContentDispositionParameters: [NetworkMultipartFormParameter(key: "time", value: "22:24"), NetworkMultipartFormParameter(key: "updated", value: "true")],
                additionalHeaders: [NetworkMultipartFormHeader(key: "Content-Encoding", value: "base64"), NetworkMultipartFormHeader(key: "Creation", value: "2000-02-02")]
            )
            let boundary = "boundary"
            var expectedData = "--boundary\r\nContent-Disposition: form-data; name=\"clave\"; time=\"22:24\"; updated=\"true\"\r\n".data(using: .utf8)
            expectedData?.append("Content-Encoding: base64\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("Creation: 2000-02-02\r\n".data(using: .utf8) ?? Data())
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            expectedData?.append(try jsonEncode.encode(json))
            expectedData?.append("\r\n".data(using: .utf8) ?? Data())
            XCTAssertEqual(try request.data(boundary: boundary), expectedData)
        }
    }
}

// creame u
