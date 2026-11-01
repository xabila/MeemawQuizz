import XCTest
@testable import MeemawQuizzCore

final class WebSocketCodecTests: XCTestCase {

    func testRFC6455HandshakeAcceptComputation() {
        // Official RFC 6455 Section 1.3 test vector
        let key = "dGhlIHNhbXBsZSBub25jZQ=="
        let accept = WebSocketFrameCodec.computeAcceptHeader(forSecWebSocketKey: key)
        XCTAssertEqual(accept, "s3pPLMBiTxaQ9kYGzzhZRbK+xOo=")
    }

    func testHTTPRequestClassificationDetectsWebPageAndWebSocketUpgrade() {
        let getHTML = """
        GET / HTTP/1.1\r
        Host: 192.168.1.25:8420\r
        User-Agent: Mozilla/5.0 (Linux; Android 15)\r
        \r
        """.data(using: .utf8)!

        let parsedHTML = WebSocketFrameCodec.classifyIncomingHTTP(getHTML)
        XCTAssertEqual(parsedHTML, .httpGetControllerPage)

        let wsUpgrade = """
        GET /ws HTTP/1.1\r
        Host: 192.168.1.25:8420\r
        Upgrade: websocket\r
        Connection: Upgrade\r
        Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r
        Sec-WebSocket-Version: 13\r
        \r
        """.data(using: .utf8)!

        let parsedWS = WebSocketFrameCodec.classifyIncomingHTTP(wsUpgrade)
        XCTAssertEqual(parsedWS, .webSocketUpgrade(secKey: "dGhlIHNhbXBsZSBub25jZQ=="))
    }

    func testMaskedClientFrameAndServerFrameRoundTrip() throws {
        let msg = ClientToHostMessage(
            playerID: "android_1",
            action: .joinOrUpdateProfile,
            playerName: "Karim",
            requestedColor: .neonCyan,
            avatarEmoji: "🦄",
            platform: .webQR
        )
        let jsonData = try JSONEncoder().encode(msg)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        let maskedFrame = WebSocketFrameCodec.encodeClientMaskedTextFrame(jsonString)
        var buffer = maskedFrame
        let extracted = WebSocketFrameCodec.extractFrames(from: &buffer)

        XCTAssertEqual(extracted.count, 1)
        XCTAssertTrue(buffer.isEmpty)
        if case .text(let receivedText) = extracted.first {
            let decoded = try JSONDecoder().decode(ClientToHostMessage.self, from: Data(receivedText.utf8))
            XCTAssertEqual(decoded, msg)
        } else {
            XCTFail("Expected text frame")
        }
    }
}
