import AVFoundation
import Foundation
import Observation
import SwiftUI
import UIKit

enum TVResolutionMode: String, CaseIterable, Identifiable, Sendable {
    case hd720p = "720p"
    case fullHD1080p = "1080p"
    case ultraHD4K = "4k"

    var id: String { rawValue }

    var maxRenderDimension: CGFloat {
        switch self {
        case .hd720p: return 1280.0
        case .fullHD1080p: return 1920.0
        case .ultraHD4K: return 3840.0
        }
    }

    var shortBadge: String {
        switch self {
        case .hd720p: return "⚡ 720P"
        case .fullHD1080p: return "💎 1080P"
        case .ultraHD4K: return "🔥 4K"
        }
    }
}

/// Gestionnaire AirPlay 16:9 & Double Écran TV dédié pour MeemawQuizz :
/// - Affiche automatiquement `MeemawTVStageView` en plein écran 16:9 sur Apple TV / HDMI (`UIWindowScene` externe + `UISceneAccessory` iOS 27), pendant que l'iPhone Hôte reste une manette Joueur + Régie en portrait.
/// - Permet aussi un aperçu plateau TV sur l'iPhone pour tester sans téléviseur.
@Observable
@MainActor
final class ExternalDisplayManager {
    static let shared = ExternalDisplayManager()

    var isAirPlayAudioConnected: Bool = false
    var isExternalTVSceneConnected: Bool = false
    var isPreviewTVOnPhoneSelected: Bool = false
    var externalScreenTitle: String = ""
    var externalScreenBoundsText: String = ""
    var activeTVDrawablePixelsText: String = "1920×1080"

    var tvResolutionMode: TVResolutionMode = {
        if let saved = UserDefaults.standard.string(forKey: "meemawquizz.tvResolutionMode"),
           let mode = TVResolutionMode(rawValue: saved) {
            return mode
        }
        return .fullHD1080p
    }() {
        didSet {
            UserDefaults.standard.set(tvResolutionMode.rawValue, forKey: "meemawquizz.tvResolutionMode")
            guard tvResolutionMode != oldValue else { return }
            applyTVResolutionToConnectedScreen()
        }
    }

    fileprivate var externalWindow: UIWindow?
    private var routePollTask: Task<Void, Never>?
    private var didStartMonitoring = false
    private var sceneAccessoryRegistration: AnyObject?
    private weak var sceneAccessoryRegistrar: UIViewController?
    private var pendingExternalWindowSceneID: ObjectIdentifier?

    private init() {}

    private var activeScreens: [UIScreen] {
        var result: [UIScreen] = [UIScreen.main]
        for scene in UIApplication.shared.connectedScenes {
            guard let ws = scene as? UIWindowScene else { continue }
            let screen = ws.screen
            if !result.contains(where: { $0 === screen }) {
                result.append(screen)
            }
        }
        for session in UIApplication.shared.openSessions {
            guard let ws = session.scene as? UIWindowScene else { continue }
            let screen = ws.screen
            if !result.contains(where: { $0 === screen }) {
                result.append(screen)
            }
        }
        return result
    }

    /// Enregistrement iOS 27 (`windowExternalDisplayNonInteractive`).
    func registerExternalDisplaySceneAccessory(from viewController: UIViewController) {
        guard #available(iOS 27, *) else { return }
        if sceneAccessoryRegistrar === viewController, sceneAccessoryRegistration != nil {
            return
        }
        if let previous = sceneAccessoryRegistrar, previous !== viewController,
           let registration = sceneAccessoryRegistration as? UISceneAccessoryRegistration {
            previous.unregisterSceneAccessory(registration)
        }
        let configuration = UISceneConfiguration(
            name: "ExternalAirPlayDisplay",
            sessionRole: .windowExternalDisplayNonInteractive
        )
        configuration.delegateClass = ExternalDisplaySceneDelegate.self
        let accessory = UISceneAccessory.externalNonInteractive(sceneConfiguration: configuration)
        let registration = viewController.registerSceneAccessory(accessory)
        sceneAccessoryRegistration = registration
        sceneAccessoryRegistrar = viewController
    }

    func startMonitoring() {
        if didStartMonitoring {
            updateAirPlayStatus()
            return
        }
        didStartMonitoring = true
        updateAirPlayStatus()
        Self.registerDisplayObservers()

        routePollTask?.cancel()
        routePollTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(1000))
                guard let self, !Task.isCancelled else { return }
                self.updateAirPlayStatus()
            }
        }
    }

    nonisolated private static func registerDisplayObservers() {
        NotificationCenter.default.addObserver(
            forName: UIScene.willConnectNotification,
            object: nil,
            queue: nil
        ) { _ in
            Task { @MainActor in
                ExternalDisplayManager.shared.attachExternalDisplayIfAvailable()
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIScene.didDisconnectNotification,
            object: nil,
            queue: nil
        ) { notification in
            let disconnectedSceneID = (notification.object as? AnyObject).map(ObjectIdentifier.init)
            Task { @MainActor in
                let mgr = ExternalDisplayManager.shared
                if let extScene = mgr.externalWindow?.windowScene,
                   ObjectIdentifier(extScene) == disconnectedSceneID {
                    mgr.detachExternalDisplay()
                } else if mgr.activeScreens.count <= 1 {
                    mgr.detachExternalDisplay()
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: nil
        ) { _ in
            Task { @MainActor in
                ExternalDisplayManager.shared.updateAirPlayStatus()
            }
        }
    }

    func updateAirPlayStatus() {
        attachExternalDisplayIfAvailable()

        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        var matchedName: String?
        for output in outputs {
            if output.portType == .airPlay || output.portType == .HDMI {
                matchedName = output.portName
                break
            }
        }

        let isScreenMirrored = activeScreens.contains { $0 !== UIScreen.main && $0.mirrored != nil }
        if let name = matchedName {
            isAirPlayAudioConnected = true
            externalScreenTitle = name
        } else if isExternalTVSceneConnected || isScreenMirrored {
            isAirPlayAudioConnected = true
            if externalScreenTitle.isEmpty {
                externalScreenTitle = "Apple TV 16:9"
            }
        } else {
            isAirPlayAudioConnected = false
            externalScreenTitle = ""
        }
    }

    func attachExternalDisplayIfAvailable() {
        let screens = activeScreens
        guard screens.count > 1 else {
            if isExternalTVSceneConnected || externalWindow != nil {
                detachExternalDisplay()
            }
            return
        }

        var foundScene: UIWindowScene?
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene,
                  windowScene.activationState != .unattached else { continue }
            let role = windowScene.session.role
            let isExternalRole = role == .windowExternalDisplayNonInteractive
                || role.rawValue.contains("External")
            let isNonMainScreen = windowScene.screen != UIScreen.main
            if (isExternalRole || isNonMainScreen) && windowScene.screen != UIScreen.main {
                foundScene = windowScene
                break
            }
        }

        if let targetScene = foundScene {
            if let existing = externalWindow, existing.windowScene === targetScene, !existing.isHidden {
                let targetBounds = targetScene.screen.bounds
                if existing.frame != targetBounds {
                    existing.frame = targetBounds
                }
                isExternalTVSceneConnected = true
                externalScreenBoundsText = "\(Int(targetBounds.width))x\(Int(targetBounds.height))"
                return
            }
            attachWindow(to: targetScene)
        }
    }

    func attachWindow(to windowScene: UIWindowScene) {
        let extScreen = windowScene.screen
        extScreen.overscanCompensation = .none
        let bounds = applyTVResolution(to: extScreen)

        isExternalTVSceneConnected = true

        if let existing = externalWindow, existing.windowScene === windowScene {
            existing.frame = bounds
            existing.windowScene = windowScene
            existing.isHidden = false
            (windowScene.delegate as? ExternalDisplaySceneDelegate)?.window = existing
            externalScreenBoundsText = "\(Int(bounds.width))x\(Int(bounds.height))"
            return
        }

        let sceneID = ObjectIdentifier(windowScene)
        if pendingExternalWindowSceneID == sceneID { return }
        pendingExternalWindowSceneID = sceneID

        Task { @MainActor in
            guard self.isExternalTVSceneConnected, self.pendingExternalWindowSceneID == sceneID else { return }
            self.pendingExternalWindowSceneID = nil
            guard self.externalWindow?.windowScene !== windowScene else { return }
            self.installExternalGameWindow(on: windowScene, bounds: extScreen.bounds)
        }
    }

    private func installExternalGameWindow(on windowScene: UIWindowScene, bounds: CGRect) {
        for existingWindow in windowScene.windows where existingWindow !== externalWindow {
            existingWindow.isHidden = true
        }

        let tvView = ExternalAirPlayTVContainerView(session: GameSessionController.shared)
        let longestSide = max(bounds.width, bounds.height, 1.0)
        let targetScale = min(3.0, max(1.0, tvResolutionMode.maxRenderDimension / longestSide))

        let hostingController = UIHostingController(rootView: tvView)
        hostingController.view.backgroundColor = .black
        hostingController.view.frame = bounds
        hostingController.view.contentScaleFactor = targetScale

        let window = UIWindow(windowScene: windowScene)
        window.frame = bounds
        window.contentScaleFactor = targetScale
        window.rootViewController = hostingController
        window.windowScene = windowScene
        window.isHidden = false
        (windowScene.delegate as? ExternalDisplaySceneDelegate)?.window = window

        externalWindow = window
        let pxW = Int((max(bounds.width, bounds.height) * targetScale).rounded())
        let pxH = Int((min(bounds.width, bounds.height) * targetScale).rounded())
        activeTVDrawablePixelsText = "\(pxW)×\(pxH)"
        externalScreenBoundsText = "\(Int(bounds.width))x\(Int(bounds.height))"
        if externalScreenTitle.isEmpty {
            externalScreenTitle = "Apple TV 16:9"
        }
    }

    func detachExternalDisplay() {
        pendingExternalWindowSceneID = nil
        if let winScene = externalWindow?.windowScene {
            (winScene.delegate as? ExternalDisplaySceneDelegate)?.window = nil
        }
        externalWindow?.rootViewController = nil
        externalWindow?.isHidden = true
        externalWindow = nil
        isExternalTVSceneConnected = false
        externalScreenBoundsText = ""
    }

    @discardableResult
    func applyTVResolution(to screen: UIScreen) -> CGRect {
        screen.overscanCompensation = .none
        if let mode = preferredScreenMode(on: screen, tier: tvResolutionMode),
           !sameScreenMode(screen.currentMode, mode) {
            screen.currentMode = mode
        }
        let bounds = screen.bounds
        let longestSide = max(bounds.width, bounds.height, 1.0)
        let targetScale = min(3.0, max(1.0, tvResolutionMode.maxRenderDimension / longestSide))
        if let window = externalWindow, window.windowScene?.screen === screen {
            window.frame = bounds
            window.contentScaleFactor = targetScale
            window.rootViewController?.view.frame = bounds
            window.rootViewController?.view.contentScaleFactor = targetScale
        }
        let pxW = Int((max(bounds.width, bounds.height) * targetScale).rounded())
        let pxH = Int((min(bounds.width, bounds.height) * targetScale).rounded())
        activeTVDrawablePixelsText = "\(pxW)×\(pxH)"
        externalScreenBoundsText = "\(Int(bounds.width))x\(Int(bounds.height))"
        return bounds
    }

    func applyTVResolutionToConnectedScreen() {
        if let screen = externalWindow?.windowScene?.screen {
            _ = applyTVResolution(to: screen)
            return
        }
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene,
                  windowScene.screen != UIScreen.main else { continue }
            _ = applyTVResolution(to: windowScene.screen)
            return
        }
    }

    private func preferredScreenMode(on screen: UIScreen, tier: TVResolutionMode) -> UIScreenMode? {
        let modes = screen.availableModes
        guard !modes.isEmpty else { return nil }
        func longSide(_ mode: UIScreenMode) -> CGFloat {
            max(mode.size.width, mode.size.height)
        }
        switch tier {
        case .ultraHD4K:
            return modes.max(by: { longSide($0) < longSide($1) })
        case .fullHD1080p:
            let capped = modes.filter { longSide($0) <= 1920.5 }
            return (capped.isEmpty ? modes : capped).min(by: { abs(longSide($0) - 1920) < abs(longSide($1) - 1920) })
        case .hd720p:
            let capped = modes.filter { longSide($0) <= 1280.5 }
            if let best = capped.max(by: { longSide($0) < longSide($1) }) {
                return best
            }
            return modes.min(by: { abs(longSide($0) - 1280) < abs(longSide($1) - 1280) })
        }
    }

    private func sameScreenMode(_ lhs: UIScreenMode?, _ rhs: UIScreenMode) -> Bool {
        guard let lhs else { return false }
        return abs(lhs.size.width - rhs.size.width) < 1 && abs(lhs.size.height - rhs.size.height) < 1
    }
}

@MainActor
final class ExternalDisplaySceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        ExternalDisplayManager.shared.attachWindow(to: windowScene)
        self.window = ExternalDisplayManager.shared.externalWindow
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        ExternalDisplayManager.shared.detachExternalDisplay()
        self.window = nil
    }
}

struct ExternalAirPlayTVContainerView: View {
    var session: GameSessionController

    var body: some View {
        GeometryReader { geo in
            let isPortraitBounds = geo.size.width < geo.size.height
            let landW = max(geo.size.width, geo.size.height)
            let landH = min(geo.size.width, geo.size.height)

            MeemawTVStageView(session: session)
                .frame(width: landW, height: landH)
                .rotationEffect(isPortraitBounds ? .degrees(90) : .degrees(0))
                .position(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
        }
        .ignoresSafeArea()
    }
}

struct SceneAccessoryHostInjector: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        AccessoryRegistrarViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private final class AccessoryRegistrarViewController: UIViewController {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            ExternalDisplayManager.shared.registerExternalDisplaySceneAccessory(from: self)
            ExternalDisplayManager.shared.startMonitoring()
        }
    }
}
