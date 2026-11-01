import Foundation
import MeemawQuizzCore
import Network

/// Serveur LAN unifié tournant sur l'iPhone Hôte (qui projette en AirPlay) :
/// 1. Annonce automatiquement le service Bonjour `_meemawquizz._tcp` pour les iPhones/iPads joueurs.
/// 2. Sert la WebApp Manette Pop-Art (`GET /`) pour les joueurs Android qui scannent le QR Code TV.
/// 3. Gère les connexions temps réel WebSocket (`/ws`) pour tous les téléphones (iOS et Android).
@MainActor
final class QuizLANServer {

    private var listener: NWListener?
    private var connections: [UUID: ClientPeerConnection] = [:]
    private(set) var listeningPort: UInt16 = 8420
    private(set) var isRunning: Bool = false
    private var retryCount: Int = 0
    private var cachedWiFiIP: String?

    var onClientMessage: ((UUID, ClientToHostMessage) -> Void)?
    var onClientDisconnected: ((UUID) -> Void)?
    var onServerStateChanged: (() -> Void)?
    var snapshotProvider: (() -> HostToClientStateSnapshot)?

    func start(preferredPort: UInt16 = 8420) {
        stop()
        retryCount = 0
        cachedWiFiIP = Self.localWiFiIPv4Address()
        startListenerInternal(portToTry: preferredPort)
    }

    private func startListenerInternal(portToTry: UInt16) {
        listener?.cancel()
        listener = nil

        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true
        params.includePeerToPeer = true

        let listenerInstance: NWListener
        if let port = NWEndpoint.Port(rawValue: portToTry),
           let created = try? NWListener(using: params, on: port) {
            listenerInstance = created
            self.listeningPort = portToTry
        } else if let created = try? NWListener(using: params) {
            listenerInstance = created
        } else {
            return
        }

        listenerInstance.service = NWListener.Service(
            name: "MeemawQuizz",
            type: "_meemawquizz._tcp"
        )

        listenerInstance.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch state {
                case .ready:
                    if let actualPort = listenerInstance.port?.rawValue {
                        self.listeningPort = actualPort
                    }
                    self.cachedWiFiIP = Self.localWiFiIPv4Address()
                    self.isRunning = true
                    self.retryCount = 0
                    self.onServerStateChanged?()
                case .failed:
                    self.isRunning = false
                    self.retryCount += 1
                    let nextPort: UInt16 = (self.retryCount <= 2) ? 8420 : UInt16(8420 + (self.retryCount - 2) % 8)
                    Task { @MainActor [weak self] in
                        try? await Task.sleep(for: .milliseconds(550))
                        guard let self, !self.isRunning else { return }
                        self.startListenerInternal(portToTry: nextPort)
                    }
                case .cancelled:
                    self.isRunning = false
                default:
                    break
                }
            }
        }

        listenerInstance.newConnectionHandler = { [weak self] nwConn in
            Task { @MainActor [weak self] in
                self?.acceptConnection(nwConn)
            }
        }

        listenerInstance.start(queue: .main)
        self.listener = listenerInstance
        self.isRunning = true
    }

    func stop() {
        for (_, peer) in connections {
            peer.cancel()
        }
        connections.removeAll()
        listener?.cancel()
        listener = nil
        isRunning = false
    }

    var joinURLString: String {
        let ip = cachedWiFiIP ?? Self.localWiFiIPv4Address() ?? "meemaw.local"
        if cachedWiFiIP == nil, ip != "meemaw.local" {
            cachedWiFiIP = ip
        }
        return "http://\(ip):\(listeningPort)"
    }

    func broadcast(_ snapshot: HostToClientStateSnapshot) {
        guard let jsonData = try? JSONEncoder().encode(snapshot),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        let frame = WebSocketFrameCodec.encodeServerTextFrame(jsonString)

        for (_, peer) in connections where peer.isWebSocketUpgraded {
            peer.sendRaw(frame)
        }
    }

    private func acceptConnection(_ nwConnection: NWConnection) {
        let connID = UUID()
        let peer = ClientPeerConnection(id: connID, connection: nwConnection)

        peer.onUpgradedToWebSocket = { [weak self] in
            guard let self, let snapshot = self.snapshotProvider?() else { return }
            if let data = try? JSONEncoder().encode(snapshot),
               let text = String(data: data, encoding: .utf8) {
                let frame = WebSocketFrameCodec.encodeServerTextFrame(text)
                peer.sendRaw(frame)
            }
        }

        peer.onMessageReceived = { [weak self] message in
            self?.onClientMessage?(connID, message)
        }

        peer.snapshotProvider = { [weak self] in
            self?.snapshotProvider?()
        }

        peer.onClosed = { [weak self] in
            self?.connections.removeValue(forKey: connID)
            self?.onClientDisconnected?(connID)
        }

        connections[connID] = peer
        peer.start()
    }

    /// Détecte l'adresse IPv4 Wi-Fi locale (`en0` / `en1` / hotspot `bridge100`) de l'iPhone Hôte.
    static func localWiFiIPv4Address() -> String? {
        var wifiAddress: String?
        var hotspotAddress: String?
        var fallbackAddress: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return nil
        }
        defer { freeifaddrs(ifaddr) }

        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let current = ptr {
            let interface = current.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                // Ignore cellular (pdp_ip*) and VPN (utun*, ipsec*) interfaces
                if !name.hasPrefix("pdp_ip") && !name.hasPrefix("utun") && !name.hasPrefix("ipsec") {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(
                        interface.ifa_addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        0,
                        NI_NUMERICHOST
                    ) == 0 {
                        let ip = String(cString: hostname)
                        if !ip.hasPrefix("127.") && !ip.hasPrefix("169.254.") {
                            if name == "en0" {
                                wifiAddress = ip
                                break
                            } else if name.hasPrefix("bridge") || name == "en1" {
                                hotspotAddress = ip
                            } else if fallbackAddress == nil {
                                fallbackAddress = ip
                            }
                        }
                    }
                }
            }
            ptr = interface.ifa_next
        }
        return wifiAddress ?? hotspotAddress ?? fallbackAddress
    }
}

// MARK: - Peer Connection Handler

@MainActor
private final class ClientPeerConnection {
    let id: UUID
    let connection: NWConnection
    private(set) var isWebSocketUpgraded = false
    private var receiveBuffer = Data()
    private var isClosed = false

    var onUpgradedToWebSocket: (() -> Void)?
    var onMessageReceived: ((ClientToHostMessage) -> Void)?
    var snapshotProvider: (() -> HostToClientStateSnapshot?)?
    var onClosed: (() -> Void)?

    init(id: UUID, connection: NWConnection) {
        self.id = id
        self.connection = connection
    }

    func start() {
        connection.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                switch state {
                case .ready:
                    self?.readLoop()
                case .failed, .cancelled:
                    self?.closeOnce()
                default:
                    break
                }
            }
        }
        connection.start(queue: .main)
    }

    func sendRaw(_ data: Data, closeAfterSend: Bool = false) {
        connection.send(content: data, completion: .contentProcessed { [weak self] _ in
            if closeAfterSend {
                Task { @MainActor [weak self] in
                    self?.cancel()
                }
            }
        })
    }

    func cancel() {
        connection.cancel()
        closeOnce()
    }

    private func closeOnce() {
        guard !isClosed else { return }
        isClosed = true
        onClosed?()
    }

    private func readLoop() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let data, !data.isEmpty {
                    self.handleIncomingBytes(data)
                }
                if isComplete || error != nil {
                    self.closeOnce()
                } else if !self.isClosed {
                    self.readLoop()
                }
            }
        }
    }

    private func handleIncomingBytes(_ data: Data) {
        receiveBuffer.append(data)

        if !isWebSocketUpgraded {
            switch WebSocketFrameCodec.classifyIncomingHTTP(receiveBuffer) {
            case .incomplete:
                return
            case .httpGetControllerPage:
                receiveBuffer.removeAll()
                let html = WebControllerHTML.render(roomCode: "MEEMAW")
                let response = WebSocketFrameCodec.buildHTMLResponse(htmlString: html)
                sendRaw(response, closeAfterSend: true)
            case .httpGetStateJSON:
                receiveBuffer.removeAll()
                let snap = snapshotProvider?()
                let jsonData = (try? JSONEncoder().encode(snap)) ?? Data("{}".utf8)
                let response = WebSocketFrameCodec.buildJSONResponse(jsonData: jsonData)
                sendRaw(response, closeAfterSend: true)
            case .httpPostActionJSON(let body):
                receiveBuffer.removeAll()
                if let msg = try? JSONDecoder().decode(ClientToHostMessage.self, from: body) {
                    onMessageReceived?(msg)
                }
                let snap = snapshotProvider?()
                let jsonData = (try? JSONEncoder().encode(snap)) ?? Data("{}".utf8)
                let response = WebSocketFrameCodec.buildJSONResponse(jsonData: jsonData)
                sendRaw(response, closeAfterSend: true)
            case .webSocketUpgrade(let secKey):
                if let range = receiveBuffer.range(of: Data("\r\n\r\n".utf8)) {
                    receiveBuffer.removeSubrange(receiveBuffer.startIndex..<range.upperBound)
                } else {
                    receiveBuffer.removeAll()
                }
                isWebSocketUpgraded = true
                let handshake = WebSocketFrameCodec.buildHandshakeResponse(secWebSocketKey: secKey)
                sendRaw(handshake)
                onUpgradedToWebSocket?()
                processWebSocketFrames()
            }
        } else {
            processWebSocketFrames()
        }
    }

    private func processWebSocketFrames() {
        let frames = WebSocketFrameCodec.extractFrames(from: &receiveBuffer)
        for frame in frames {
            switch frame {
            case .text(let jsonString):
                if let msg = try? JSONDecoder().decode(ClientToHostMessage.self, from: Data(jsonString.utf8)) {
                    onMessageReceived?(msg)
                }
            case .ping(let payload):
                let pong = WebSocketFrameCodec.encodeServerPongFrame(payload)
                sendRaw(pong)
            case .close:
                cancel()
            case .pong:
                break
            }
        }
    }
}
