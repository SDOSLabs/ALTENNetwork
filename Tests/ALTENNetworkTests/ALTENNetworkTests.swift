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
}
