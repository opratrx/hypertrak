import CoreMotion
import WatchConnectivity
import SwiftUI

class WatchMotionManager: NSObject, ObservableObject {
    private let motionManager = CMMotionManager()
    private var session: WCSession?

    override init() {
        super.init()
        setupWatchConnectivity()
        startMotionUpdates()
    }

    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            print("✅ WatchConnectivity activated on Watch")
        } else {
            print("❌ WatchConnectivity is not supported on this Watch")
        }
    }

    private func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01 // High frequency updates
            motionManager.startDeviceMotionUpdates(to: .main) { data, error in
                guard let motion = data else { return }

                let accelerationZ = motion.userAcceleration.z * 9.81 // Convert to m/s²

                if let session = self.session, session.isReachable {
                    let message = ["gForceZ": accelerationZ]
                    session.sendMessage(message, replyHandler: nil) { error in
                        print("❌ Failed to send motion data: \(error.localizedDescription)")
                    }
                    print("📡 Sent motion data to iPhone: \(accelerationZ) m/s²")
                } else {
                    print("❌ WCSession is not reachable from Watch")
                }
            }
        } else {
            print("❌ Motion tracking not available on Watch")
        }
    }
}

// ✅ Implement WatchConnectivity Delegate
extension WatchMotionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        if state == .activated {
            print("✅ WatchConnectivity activated on Watch")
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("🔄 WatchConnectivity reachability changed: \(session.isReachable)")
    }
}