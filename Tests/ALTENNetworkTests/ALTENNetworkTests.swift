import XCTest
@testable import ALTENNetwork

final class ALTENNetworkTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(try? NetworkRequest(url: "https://google.es").asURLRequest().url?.absoluteString, "https://google.es")
        
        XCTAssertEqual(try? NetworkRequest(url: "https://google.es", query: [.query(key: "key", value: "value")]).asURLRequest().url?.absoluteString, "https://google.es?key=value")
        
        XCTAssertEqual(try? NetworkRequest(url: "https://google.es", query: [.query(key: "key", value: "value")]).asURLRequest().url?.absoluteString, "https://google.es?key=value")
        
        XCTAssertEqual(try? NetworkRequest(url: "https://google.es", query: [.query(key: "key", value: "!$&'()*+,;=")]).asURLRequest().url?.absoluteString, "https://google.es?key=!$%26\'()*+,;%3D")
        
        XCTAssertEqual(try? NetworkRequest(url: "https://google.es", query: [.query(key: "key", value: "!$&'()*+, ;=")]).asURLRequest().url?.absoluteString, "https://google.es?key=!$%26'()*+,%20;%3D")
    }
}
