import CryptoKit
import Foundation

public enum IncomingHTTPClassification: Equatable, Sendable {
    case incomplete
    case httpGetControllerPage
    case webSocketUpgrade(secKey: String)
}

public enum DecodedWebSocketFrame: Equatable, Sendable {
    case text(String)
    case ping(Data)
    case pong(Data)
    case close
}

public enum WebSocketFrameCodec {

    private static let rfc6455MagicGUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

    /// Calcule la valeur `Sec-WebSocket-Accept` conforme à la RFC 6455.
    public static func computeAcceptHeader(forSecWebSocketKey key: String) -> String {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let combined = trimmed + rfc6455MagicGUID
        let digest = Insecure.SHA1.hash(data: Data(combined.utf8))
        return Data(digest).base64EncodedString()
    }

    /// Analyse le tampon HTTP initial pour déterminer s'il s'agit d'un `GET /` (page Web Android/QR)
    /// ou d'un `Upgrade: websocket` (manette temps réel iOS ou Android).
    public static func classifyIncomingHTTP(_ data: Data) -> IncomingHTTPClassification {
        guard let raw = String(data: data, encoding: .utf8) else {
            return .httpGetControllerPage
        }
        guard raw.contains("\r\n\r\n") || raw.contains("\n\n") || raw.hasSuffix("\r\n\r") else {
            return .incomplete
        }
        let lines = raw.components(separatedBy: CharacterSet.newlines)
        var isUpgrade = false
        var secKey: String?

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let lower = trimmed.lowercased()
            if lower.hasPrefix("upgrade:") && lower.contains("websocket") {
                isUpgrade = true
            } else if lower.hasPrefix("sec-websocket-key:") {
                let parts = trimmed.split(separator: ":", maxSplits: 1)
                if parts.count == 2 {
                    secKey = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }

        if isUpgrade, let secKey, !secKey.isEmpty {
            return .webSocketUpgrade(secKey: secKey)
        }
        return .httpGetControllerPage
    }

    /// Construit la réponse HTTP 101 Switching Protocols pour finaliser le handshake WebSocket.
    public static func buildHandshakeResponse(secWebSocketKey: String) -> Data {
        let accept = computeAcceptHeader(forSecWebSocketKey: secWebSocketKey)
        let headers = [
            "HTTP/1.1 101 Switching Protocols",
            "Upgrade: websocket",
            "Connection: Upgrade",
            "Sec-WebSocket-Accept: \(accept)",
            "\r\n"
        ].joined(separator: "\r\n")
        return Data(headers.utf8)
    }

    /// Construit une requête HTTP Upgrade WebSocket (utilisée par le client iOS Bonjour).
    public static func buildClientHandshakeRequest(host: String = "meemaw.local") -> Data {
        let randomKey = Data((0..<16).map { _ in UInt8.random(in: 0...255) }).base64EncodedString()
        let req = [
            "GET /ws HTTP/1.1",
            "Host: \(host)",
            "Upgrade: websocket",
            "Connection: Upgrade",
            "Sec-WebSocket-Key: \(randomKey)",
            "Sec-WebSocket-Version: 13",
            "\r\n"
        ].joined(separator: "\r\n")
        return Data(req.utf8)
    }

    /// Construit une réponse HTTP 200 complète contenant la WebApp HTML5 Pop-Art pour Android / QR Code.
    public static func buildHTMLResponse(htmlString: String) -> Data {
        let body = Data(htmlString.utf8)
        let header = [
            "HTTP/1.1 200 OK",
            "Content-Type: text/html; charset=utf-8",
            "Content-Length: \(body.count)",
            "Cache-Control: no-store, no-cache, must-revalidate",
            "Connection: close",
            "\r\n"
        ].joined(separator: "\r\n")
        var response = Data(header.utf8)
        response.append(body)
        return response
    }

    /// Encode une trame texte envoyée par le Serveur (non masquée selon RFC 6455).
    public static func encodeServerTextFrame(_ text: String) -> Data {
        encodeFrame(opcode: 0x01, payload: Data(text.utf8), masked: false)
    }

    /// Encode une trame Pong envoyée par le Serveur.
    public static func encodeServerPongFrame(_ payload: Data = Data()) -> Data {
        encodeFrame(opcode: 0x0A, payload: payload, masked: false)
    }

    /// Encode une trame texte envoyée par un Client (masquée selon RFC 6455).
    public static func encodeClientMaskedTextFrame(_ text: String) -> Data {
        encodeFrame(opcode: 0x01, payload: Data(text.utf8), masked: true)
    }

    private static func encodeFrame(opcode: UInt8, payload: Data, masked: Bool) -> Data {
        var frame = Data()
        frame.append(0x80 | (opcode & 0x0F)) // FIN = 1

        let maskBit: UInt8 = masked ? 0x80 : 0x00
        let count = payload.count
        if count <= 125 {
            frame.append(maskBit | UInt8(count))
        } else if count <= 65535 {
            frame.append(maskBit | 126)
            var len16 = UInt16(count).bigEndian
            withUnsafeBytes(of: &len16) { frame.append(contentsOf: $0) }
        } else {
            frame.append(maskBit | 127)
            var len64 = UInt64(count).bigEndian
            withUnsafeBytes(of: &len64) { frame.append(contentsOf: $0) }
        }

        if masked {
            let maskKey: [UInt8] = [0x37, 0xFA, 0x21, 0x3D]
            frame.append(contentsOf: maskKey)
            var maskedBytes = [UInt8](repeating: 0, count: count)
            for (i, byte) in payload.enumerated() {
                maskedBytes[i] = byte ^ maskKey[i & 3]
            }
            frame.append(contentsOf: maskedBytes)
        } else {
            frame.append(payload)
        }
        return frame
    }

    /// Extrait toutes les trames WebSocket complètes présentes dans `buffer` et avance le tampon.
    public static func extractFrames(from buffer: inout Data) -> [DecodedWebSocketFrame] {
        var frames: [DecodedWebSocketFrame] = []

        while buffer.count >= 2 {
            let bytes = [UInt8](buffer)
            let opcode = bytes[0] & 0x0F
            let isMasked = (bytes[1] & 0x80) != 0
            var payloadLen = Int(bytes[1] & 0x7F)
            var headerOffset = 2

            if payloadLen == 126 {
                guard bytes.count >= 4 else { break }
                payloadLen = (Int(bytes[2]) << 8) | Int(bytes[3])
                headerOffset = 4
            } else if payloadLen == 127 {
                guard bytes.count >= 10 else { break }
                var len64 = 0
                for i in 2..<10 {
                    len64 = (len64 << 8) | Int(bytes[i])
                }
                payloadLen = len64
                headerOffset = 10
            }

            let maskLen = isMasked ? 4 : 0
            let totalFrameSize = headerOffset + maskLen + payloadLen
            guard bytes.count >= totalFrameSize else { break }

            let payloadStart = headerOffset + maskLen
            var payloadBytes = Array(bytes[payloadStart..<totalFrameSize])

            if isMasked {
                let maskKey = Array(bytes[headerOffset..<(headerOffset + 4)])
                for i in 0..<payloadBytes.count {
                    payloadBytes[i] ^= maskKey[i & 3]
                }
            }

            buffer.removeFirst(totalFrameSize)
            let payloadData = Data(payloadBytes)

            switch opcode {
            case 0x01: // Text
                if let text = String(data: payloadData, encoding: .utf8) {
                    frames.append(.text(text))
                }
            case 0x08: // Close
                frames.append(.close)
            case 0x09: // Ping
                frames.append(.ping(payloadData))
            case 0x0A: // Pong
                frames.append(.pong(payloadData))
            default:
                break
            }
        }

        return frames
    }
}
