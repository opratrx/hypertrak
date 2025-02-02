//
//  PremiumSettingsView.swift
//  InAppPurchaseKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/inapppurchasekit/settings
//

import AnalyticsKit
import SharedKit
import SwiftUI

/// You can add specific settings or actions for users who have purchased a premium subscription.
public struct PremiumSettingsView: View {

	@EnvironmentObject var iap: InAppPurchases
	let popBackToSettings: () -> Void

	public init(popBackToRoot: @escaping () -> Void) {
		self.popBackToSettings = popBackToRoot
	}

	public var body: some View {
		VStack {
			Spacer()

			HeroView(
				sfSymbolName: "star.fill",
				title: "You're all set.",
				subtitle: "You have Access to Premium Features.",
				bounceOnAppear: true
			)
			Spacer()

			Button("Manage Subscription") {
				Task {
					await InAppPurchases.showSubscriptionManagementScreen()
				}
			}
			.buttonStyle(.secondary())
			.captureTaps("manage_subscription_btn", fromView: "PremiumSettingsView")
		}
		.padding()
		.navigationTitle("\(Constants.AppData.appName) Premium")
		.navigationBarTitleDisplayMode(.inline)
		.requirePremium(iap: iap, onCancel: popBackToSettings)
		.captureViewActivity(as: "InAppPurchaseView")
	}
}

#Preview {
	NavigationView {
		PremiumSettingsView(popBackToRoot: {})
			.environmentObject(InAppPurchases())
	}
}
