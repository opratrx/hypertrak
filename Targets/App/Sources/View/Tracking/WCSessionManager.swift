import WatchConnectivity

class WCSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WCSessionManager()
    
    @Published var isTracking = false
    
    private override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("✅ WCSession activated")
        }
    }

    func toggleTracking() {
        isTracking.toggle()
        sendTrackingState()
    }
    
    private func sendTrackingState() {
        guard WCSession.default.isReachable else {
            print("❌ Watch is not reachable")
            return
        }
        let message: [String: Any] = ["isTracking": isTracking]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("❌ Failed to sync tracking state: \(error.localizedDescription)")
        }
    }

    // ✅ Receive messages from the Watch
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let watchTrackingState = message["isTracking"] as? Bool {
                self.isTracking = watchTrackingState
                print("📡 Synced tracking state from Watch: \(watchTrackingState)")
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
    func sessionReachabilityDidChange(_ session: WCSession) {}
}