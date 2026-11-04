import Foundation
import MeemawQuizzCore
import Network

/// Client iOS (`_meemawquizz._tcp` + Auto-Hotspot `172.20.10.1`) :
/// 1. Découvre automatiquement le salon AirPlay sur le Wi-Fi local via Bonjour.
/// 2. En Partage de connexion iOS (où Bonjour multicast est parfois filtré par iOS),
///    tente automatiquement la connexion directe à la passerelle Hotspot `172.20.10.1:8420`.
@MainActor
final class QuizBonjourClient {

    private var browser: NWBrowser?
    private var connection: NWConnection?
    private var hotspotFallbackTask: Task<Void, Never>?
    private var receiveBuffer = Data()
    private var isHandshakeCompleted = false

    private(set) var discoveredHostName: String?
    private(set) var isConnectedToHost: Bool = false

    var onSnapshotReceived: ((HostToClientStateSnapshot) -> Void)?
    var onConnectionStateChanged: ((Bool) -> Void)?

    func startAutoDiscovery() {
        stop()

        let params = NWParameters.tcp
        params.includePeerToPeer = true
        let descriptor = NWBrowser.Descriptor.bonjour(type: "_meemawquizz._tcp", domain: nil)
        let nwBrowser = NWBrowser(for: descriptor, using: params)

        nwBrowser.browseResultsChangedHandler = { [weak self] results, _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard !self.isConnectedToHost, self.connection == nil else { return }
                if let firstResult = results.first {
                    if case let .service(name, _, _, _) = firstResult.endpoint {
                        self.discoveredHostName = name
                    }
                    self.connect(to: firstResult.endpoint)
                }
            }
        }

        nwBrowser.start(queue: .main)
        self.browser = nwBrowser

        // En extérieur (Partage de connexion iOS), Bonjour mDNS peut être filtré sur bridge100 :
        // on tente aussi automatiquement l'IP passerelle du Partage de connexion iPhone (172.20.10.1:8420) !
        hotspotFallbackTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(1200))
                guard let self, !Task.isCancelled else { return }
                if !self.isConnectedToHost && self.connection == nil {
                    self.connectToDirectHost(host: "172.20.10.1", port: 8420)
                }
                try? await Task.sleep(for: .milliseconds(2500))
            }
        }
    }

    func connectToDirectHost(host: String, port: UInt16 = 8420) {
        let cleanedHost = host
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .split(separator: ":")
            .first
            .map(String.init) ?? host

        guard !cleanedHost.isEmpty, let nwPort = NWEndpoint.Port(rawValue: port) else { return }
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(cleanedHost), port: nwPort)
        connect(to: endpoint)
    }

    func stop() {
        hotspotFallbackTask?.cancel()
        hotspotFallbackTask = nil
        connection?.cancel()
        connection = nil
        browser?.cancel()
        browser = nil
        receiveBuffer.removeAll()
        isHandshakeCompleted = false
        if isConnectedToHost {
            isConnectedToHost = false
            onConnectionStateChanged?(false)
        }
    }

    func send(_ message: ClientToHostMessage) {
        guard isConnectedToHost, isHandshakeCompleted,
              let data = try? JSONEncoder().encode(message),
              let text = String(data: data, encoding: .utf8) else { return }
        let frame = WebSocketFrameCodec.encodeClientMaskedTextFrame(text)
        connection?.send(content: frame, completion: .contentProcessed { _ in })
    }

    private func connect(to endpoint: NWEndpoint) {
        connection?.cancel()
        receiveBuffer.removeAll()
        isHandshakeCompleted = false

        let params = NWParameters.tcp
        params.includePeerToPeer = true
        let conn = NWConnection(to: endpoint, using: params)

        conn.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch state {
                case .ready:
                    let handshakeReq = WebSocketFrameCodec.buildClientHandshakeRequest()
                    conn.send(content: handshakeReq, completion: .contentProcessed { _ in })
                    self.readLoop(on: conn)
                case .failed, .cancelled:
                    if self.connection === conn {
                        self.connection = nil
                    }
                    self.isHandshakeCompleted = false
                    if self.isConnectedToHost {
                        self.isConnectedToHost = false
                        self.onConnectionStateChanged?(false)
                    }
                default:
                    break
                }
            }
        }

        conn.start(queue: .main)
        self.connection = conn
    }

    private func readLoop(on conn: NWConnection) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            Task { @MainActor [weak self] in
                guard let self, self.connection === conn else { return }
                if let data, !data.isEmpty {
                    self.handleIncomingBytes(data)
                }
                if isComplete || error != nil {
                    conn.cancel()
                } else {
                    self.readLoop(on: conn)
                }
            }
        }
    }

    private func handleIncomingBytes(_ data: Data) {
        receiveBuffer.append(data)

        if !isHandshakeCompleted {
            if let range = receiveBuffer.range(of: Data("\r\n\r\n".utf8)) {
                receiveBuffer.removeSubrange(receiveBuffer.startIndex..<range.upperBound)
                isHandshakeCompleted = true
                isConnectedToHost = true
                onConnectionStateChanged?(true)
            } else {
                return
            }
        }

        let frames = WebSocketFrameCodec.extractFrames(from: &receiveBuffer)
        for frame in frames {
            switch frame {
            case .text(let json):
                if let snapshot = try? JSONDecoder().decode(HostToClientStateSnapshot.self, from: Data(json.utf8)) {
                    onSnapshotReceived?(snapshot)
                }
            case .close:
                connection?.cancel()
            default:
                break
            }
        }
    }
}
