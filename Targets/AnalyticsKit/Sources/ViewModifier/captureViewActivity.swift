//
//  captureViewActivity.swift
//  AnalyticsKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/analyticskit/capture-view-activity
//

import PostHog
import SwiftUI

struct CaptureScreenModifier: ViewModifier {

	@Environment(\.scenePhase) var scenePhase
	let viewName: String

	func body(content: Content) -> some View {
		content
			.onAppear {
				captureScreenView(viewName)
			}
	}

	private func captureScreenView(_ screenName: String) {
		print("[ANALYTICS] Captured active screen: \(screenName)")

		PostHogSDK.shared.screen(screenName)
	}

}

extension View {
	/// This modifier will notify PostHog when a View is active
	public func captureViewActivity(as viewName: String) -> some View {
		modifier(CaptureScreenModifier(viewName: viewName))
	}
}
