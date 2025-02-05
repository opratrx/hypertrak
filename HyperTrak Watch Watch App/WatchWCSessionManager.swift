import WatchConnectivity
import Foundation

class WatchWCSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchWCSessionManager()
    
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
            print("✅ Watch WCSession activated")
        }
    }

    func toggleTracking() {
        isTracking.toggle()
        sendTrackingState()
    }
    
    private func sendTrackingState() {
        guard WCSession.default.isReachable else {
            print("❌ iPhone is not reachable")
            return
        }
        let message: [String: Any] = ["isTracking": isTracking]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("❌ Failed to sync tracking state: \(error.localizedDescription)")
        }
    }

    // ✅ Receive messages from the iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let phoneTrackingState = message["isTracking"] as? Bool {
                self.isTracking = phoneTrackingState
                print("📡 Synced tracking state from iPhone: \(phoneTrackingState)")
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
    func sessionReachabilityDidChange(_ session: WCSession) {}
}