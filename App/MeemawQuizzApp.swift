import SwiftUI

@main
struct MeemawQuizzApp: App {
    @State private var session = GameSessionController.shared

    var body: some Scene {
        WindowGroup {
            PlayerControllerView(session: session)
                .onAppear {
                    ExternalDisplayManager.shared.startMonitoring()
                }
        }
    }
}
