import Darwin
import Foundation
import MeemawQuizzCore
import Network

/// Serveur LAN & Partage de Connexion (Hotspot `bridge100` / `172.20.10.1`) tournant sur l'iPhone Hôte :
/// 1. Écoute au niveau noyau POSIX sur `0.0.0.0:8420` / `[::]:8420` (`INADDR_ANY`) pour accepter immédiatement
///    les connexions Wi-Fi (`en0`) ET Partage de connexion iOS (`bridge100` / `172.20.10.1`), même si l'interface
///    Hotspot est créée dynamiquement après le lancement de l'application.
/// 2. Annonce automatiquement le service Bonjour `_meemawquizz._tcp` (`includesPeerToPeer = true`) pour les iPhones/iPads.
/// 3. Sert la WebApp Manette (`GET /`) et les WebSockets (`/ws`) pour tous les téléphones qui scannent le QR Code.
@MainActor
final class QuizLANServer: NSObject, NetServiceDelegate {

    enum NetworkMode: String, Sendable {
        case wifiLAN
        case personalHotspotActive
        case personalHotspotStandby
    }

    private var serverSocketFD: Int32 = -1
    private var acceptSource: DispatchSourceRead?
    private var netService: NetService?
    private var interfaceMonitorTimer: Timer?
    private var connections: [UUID: ClientPeerConnection] = [:]

    private(set) var listeningPort: UInt16 = 8420
    private(set) var isRunning: Bool = false
    private(set) var detectedIP: String = "172.20.10.1"
    private(set) var networkMode: NetworkMode = .personalHotspotStandby

    /// Permet à l'utilisateur de forcer l'affichage du QR Code sur l'IP Partage de connexion (`172.20.10.1`)
    var forceHotspotIP: Bool = false {
        didSet {
            refreshNetworkAddressAndNotifyIfNeeded(forceNotify: true)
        }
    }

    var onClientMessage: ((UUID, ClientToHostMessage) -> Void)?
    var onClientDisconnected: ((UUID) -> Void)?
    var onServerStateChanged: (() -> Void)?
    var snapshotProvider: (() -> HostToClientStateSnapshot)?

    func start(preferredPort: UInt16 = 8420) {
        stop()
        refreshDetectedNetworkStatus()
        startPOSIXListener(preferredPort: preferredPort)
        startInterfaceMonitor()
    }

    func stop() {
        interfaceMonitorTimer?.invalidate()
        interfaceMonitorTimer = nil

        for (_, peer) in connections {
            peer.cancel()
        }
        connections.removeAll()

        netService?.stop()
        netService = nil

        if let source = acceptSource {
            acceptSource = nil
            source.cancel()
        } else if serverSocketFD >= 0 {
            Darwin.close(serverSocketFD)
            serverSocketFD = -1
        }
        isRunning = false
    }

    var joinURLString: String {
        let status = Self.detectNetworkAddresses()
        let ip: String
        if forceHotspotIP {
            ip = status.hotspotIP ?? "172.20.10.1"
        } else if let hotspot = status.hotspotIP {
            ip = hotspot
        } else if let wifi = status.wifiIP {
            ip = wifi
        } else {
            // En extérieur sur 4G/5G sans Wi-Fi : l'IP du Partage de connexion iOS est toujours 172.20.10.1
            ip = "172.20.10.1"
        }
        return "http://\(ip):\(listeningPort)"
    }

    func refreshNetworkAddressAndNotifyIfNeeded(forceNotify: Bool = false) {
        let oldIP = detectedIP
        let oldMode = networkMode
        refreshDetectedNetworkStatus()
        if forceNotify || oldIP != detectedIP || oldMode != networkMode {
            onServerStateChanged?()
        }
    }

    private func refreshDetectedNetworkStatus() {
        let status = Self.detectNetworkAddresses()
        if forceHotspotIP {
            detectedIP = status.hotspotIP ?? "172.20.10.1"
            networkMode = status.hotspotIP != nil ? .personalHotspotActive : .personalHotspotStandby
        } else if let hotspot = status.hotspotIP {
            detectedIP = hotspot
            networkMode = .personalHotspotActive
        } else if let wifi = status.wifiIP {
            detectedIP = wifi
            networkMode = .wifiLAN
        } else {
            detectedIP = "172.20.10.1"
            networkMode = .personalHotspotStandby
        }
    }

    private func startInterfaceMonitor() {
        interfaceMonitorTimer?.invalidate()
        interfaceMonitorTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshNetworkAddressAndNotifyIfNeeded()
            }
        }
    }

    private func startPOSIXListener(preferredPort: UInt16) {
        let portsToTry: [UInt16] = [preferredPort, 8421, 8422, 8423, 8424, 0]
        var boundFD: Int32 = -1
        var actualPort: UInt16 = preferredPort

        for candidatePort in portsToTry {
            let fd = Darwin.socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP)
            guard fd >= 0 else { continue }

            var yes: Int32 = 1
            var no: Int32 = 0
            _ = setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &yes, socklen_t(MemoryLayout<Int32>.size))
            _ = setsockopt(fd, SOL_SOCKET, SO_REUSEPORT, &yes, socklen_t(MemoryLayout<Int32>.size))
            _ = setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &yes, socklen_t(MemoryLayout<Int32>.size))
            // Dual-stack IPv4 + IPv6 sur toutes les interfaces (en0, bridge100 Hotspot, awdl0, lo0)
            _ = setsockopt(fd, IPPROTO_IPV6, IPV6_V6ONLY, &no, socklen_t(MemoryLayout<Int32>.size))

            let flags = fcntl(fd, F_GETFL, 0)
            _ = fcntl(fd, F_SETFL, flags | O_NONBLOCK)

            var addr = sockaddr_in6()
            addr.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
            addr.sin6_family = sa_family_t(AF_INET6)
            addr.sin6_port = candidatePort.bigEndian
            addr.sin6_addr = in6addr_any

            let bindResult = withUnsafePointer(to: &addr) { ptr in
                ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                    Darwin.bind(fd, sockPtr, socklen_t(MemoryLayout<sockaddr_in6>.size))
                }
            }

            if bindResult == 0 && Darwin.listen(fd, 32) == 0 {
                var assignedAddr = sockaddr_in6()
                var assignedLen = socklen_t(MemoryLayout<sockaddr_in6>.size)
                _ = withUnsafeMutablePointer(to: &assignedAddr) { ptr in
                    ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                        Darwin.getsockname(fd, sockPtr, &assignedLen)
                    }
                }
                boundFD = fd
                actualPort = UInt16(bigEndian: assignedAddr.sin6_port)
                break
            } else {
                Darwin.close(fd)
            }
        }

        guard boundFD >= 0 else {
            isRunning = false
            return
        }

        self.serverSocketFD = boundFD
        self.listeningPort = actualPort
        self.isRunning = true

        let source = DispatchSource.makeReadSource(fileDescriptor: boundFD, queue: .main)
        source.setEventHandler { [weak self] in
            self?.acceptPendingConnections()
        }
        source.setCancelHandler { [weak self] in
            if boundFD >= 0 {
                Darwin.close(boundFD)
            }
            Task { @MainActor [weak self] in
                if self?.serverSocketFD == boundFD {
                    self?.serverSocketFD = -1
                }
            }
        }
        source.resume()
        self.acceptSource = source

        publishBonjourService(port: actualPort)
        onServerStateChanged?()
    }

    private func publishBonjourService(port: UInt16) {
        netService?.stop()
        let service = NetService(domain: "local.", type: "_meemawquizz._tcp.", name: "MeemawQuizz", port: Int32(port))
        service.includesPeerToPeer = true
        service.delegate = self
        service.publish()
        self.netService = service
    }

    private func acceptPendingConnections() {
        guard serverSocketFD >= 0 else { return }
        while true {
            var clientAddr = sockaddr_storage()
            var clientAddrLen = socklen_t(MemoryLayout<sockaddr_storage>.size)
            let clientFD = withUnsafeMutablePointer(to: &clientAddr) { ptr in
                ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                    Darwin.accept(serverSocketFD, sockPtr, &clientAddrLen)
                }
            }
            if clientFD < 0 {
                break
            }
            acceptSocketConnection(clientFD)
        }
    }

    func broadcast(_ snapshot: HostToClientStateSnapshot) {
        guard let jsonData = try? JSONEncoder().encode(snapshot),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        let frame = WebSocketFrameCodec.encodeServerTextFrame(jsonString)

        for (_, peer) in connections where peer.isWebSocketUpgraded {
            peer.sendRaw(frame)
        }
    }

    private func acceptSocketConnection(_ clientFD: Int32) {
        let connID = UUID()
        let peer = ClientPeerConnection(id: connID, socketFD: clientFD)

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

    /// Détecte séparément l'adresse IPv4 du Partage de connexion iOS (`bridge100` / `ap*` / `172.20.10.x`)
    /// et l'adresse IPv4 du Wi-Fi local (`en0` / `en1`).
    static func detectNetworkAddresses() -> (hotspotIP: String?, wifiIP: String?) {
        var wifiAddress: String?
        var hotspotAddress: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return (nil, nil)
        }
        defer { freeifaddrs(ifaddr) }

        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let current = ptr {
            let interface = current.pointee
            if let addr = interface.ifa_addr, addr.pointee.sa_family == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                // Ignorer les interfaces cellulaires (pdp_ip*), VPN (utun*, ipsec*) et internes (anpi*, llw*, awdl*)
                let isIgnored = name.hasPrefix("pdp_ip")
                    || name.hasPrefix("utun")
                    || name.hasPrefix("ipsec")
                    || name.hasPrefix("anpi")
                    || name.hasPrefix("llw")
                    || name.hasPrefix("awdl")
                    || name.hasPrefix("lo")
                if !isIgnored {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(
                        addr,
                        socklen_t(addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        0,
                        NI_NUMERICHOST
                    ) == 0 {
                        let ip = String(cString: hostname)
                        if isPrivateLANIPv4(ip) {
                            if name.hasPrefix("bridge") || name.hasPrefix("ap") || ip.hasPrefix("172.20.10.") {
                                hotspotAddress = ip
                            } else if name == "en0" || name == "en1" {
                                wifiAddress = ip
                            }
                        }
                    }
                }
            }
            ptr = interface.ifa_next
        }
        return (hotspotAddress, wifiAddress)
    }

    static func localWiFiIPv4Address() -> String? {
        let detected = detectNetworkAddresses()
        return detected.hotspotIP ?? detected.wifiIP
    }

    private static func isPrivateLANIPv4(_ ip: String) -> Bool {
        if ip.hasPrefix("192.168.") || ip.hasPrefix("10.") || ip.hasPrefix("172.20.10.") {
            return true
        }
        if ip.hasPrefix("172.") {
            let parts = ip.split(separator: ".")
            if parts.count == 4, let second = Int(parts[1]), (16...31).contains(second) {
                return true
            }
        }
        return false
    }
}

// MARK: - Peer Connection Handler (POSIX Non-Blocking Socket)

@MainActor
private final class ClientPeerConnection {
    let id: UUID
    private var socketFD: Int32
    private var readSource: DispatchSourceRead?
    private(set) var isWebSocketUpgraded = false
    private var receiveBuffer = Data()
    private var outgoingBuffer = Data()
    private var shouldCloseAfterFlush = false
    private var isClosed = false

    var onUpgradedToWebSocket: (() -> Void)?
    var onMessageReceived: ((ClientToHostMessage) -> Void)?
    var snapshotProvider: (() -> HostToClientStateSnapshot?)?
    var onClosed: (() -> Void)?

    init(id: UUID, socketFD: Int32) {
        self.id = id
        self.socketFD = socketFD

        var yes: Int32 = 1
        _ = setsockopt(socketFD, SOL_SOCKET, SO_NOSIGPIPE, &yes, socklen_t(MemoryLayout<Int32>.size))
        _ = setsockopt(socketFD, IPPROTO_TCP, TCP_NODELAY, &yes, socklen_t(MemoryLayout<Int32>.size))
        let flags = fcntl(socketFD, F_GETFL, 0)
        _ = fcntl(socketFD, F_SETFL, flags | O_NONBLOCK)
    }

    func start() {
        guard socketFD >= 0 else { return }
        let fd = socketFD
        let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: .main)
        source.setEventHandler { [weak self] in
            self?.readAvailableBytes()
        }
        source.setCancelHandler {
            if fd >= 0 {
                Darwin.close(fd)
            }
        }
        source.resume()
        self.readSource = source
    }

    func sendRaw(_ data: Data, closeAfterSend: Bool = false) {
        guard !isClosed, socketFD >= 0 else { return }
        outgoingBuffer.append(data)
        if closeAfterSend {
            shouldCloseAfterFlush = true
        }
        flushOutgoingBuffer()
    }

    private func flushOutgoingBuffer() {
        guard !isClosed, socketFD >= 0 else { return }
        while !outgoingBuffer.isEmpty {
            let written: Int = outgoingBuffer.withUnsafeBytes { rawBuf in
                guard let base = rawBuf.baseAddress else { return 0 }
                return Darwin.send(socketFD, base, rawBuf.count, 0)
            }
            if written > 0 {
                outgoingBuffer.removeFirst(written)
            } else if written < 0 && (errno == EAGAIN || errno == EWOULDBLOCK || errno == EINTR) {
                Task { @MainActor [weak self] in
                    try? await Task.sleep(for: .milliseconds(15))
                    self?.flushOutgoingBuffer()
                }
                return
            } else {
                closeOnce()
                return
            }
        }

        if shouldCloseAfterFlush && outgoingBuffer.isEmpty {
            closeOnce()
        }
    }

    func cancel() {
        closeOnce()
    }

    private func closeOnce() {
        guard !isClosed else { return }
        isClosed = true
        if let source = readSource {
            readSource = nil
            socketFD = -1
            source.cancel()
        } else if socketFD >= 0 {
            Darwin.close(socketFD)
            socketFD = -1
        }
        onClosed?()
    }

    private func readAvailableBytes() {
        guard !isClosed, socketFD >= 0 else { return }
        var temp = [UInt8](repeating: 0, count: 65536)
        while true {
            let n = Darwin.read(socketFD, &temp, temp.count)
            if n > 0 {
                handleIncomingBytes(Data(bytes: temp, count: n))
                if isClosed { return }
            } else if n == 0 {
                closeOnce()
                return
            } else {
                if errno == EAGAIN || errno == EWOULDBLOCK || errno == EINTR {
                    break
                } else {
                    closeOnce()
                    return
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
            case .webSocketUpgrade(let clientKey):
                receiveBuffer.removeAll()
                isWebSocketUpgraded = true
                let handshake = WebSocketFrameCodec.buildHandshakeResponse(secWebSocketKey: clientKey)
                sendRaw(handshake, closeAfterSend: false)
                onUpgradedToWebSocket?()
            default:
                let html = WebControllerHTML.render(roomCode: "MEEMAW")
                let response = WebSocketFrameCodec.buildHTMLResponse(htmlString: html)
                sendRaw(response, closeAfterSend: true)
            }
            return
        }

        let frames = WebSocketFrameCodec.extractFrames(from: &receiveBuffer)
        for frame in frames {
            switch frame {
            case .text(let jsonString):
                if let jsonData = jsonString.data(using: .utf8),
                   let message = try? JSONDecoder().decode(ClientToHostMessage.self, from: jsonData) {
                    onMessageReceived?(message)
                }
            case .ping(let payload):
                var pong = Data([0x8A, UInt8(min(payload.count, 125))])
                pong.append(payload.prefix(125))
                sendRaw(pong)
            case .close:
                closeOnce()
            default:
                break
            }
        }
    }
}
