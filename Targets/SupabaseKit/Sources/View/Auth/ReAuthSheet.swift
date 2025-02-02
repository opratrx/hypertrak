//
//  ReAuthSheet.swift
//  SupabaseKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/authkit#reauthsheetswift
//

import AnalyticsKit
import AuthenticationServices
import SharedKit
import SwiftUI

public enum ReAuthResult {
	case success
	case canceled
}

// NOTE: - This is a custom sheet that that can be used to re-authenticate a user before performing a sensitive operation.

public struct ReAuthSheetView: View {

	@EnvironmentObject var db: DB
	@State private var loginErrorMessage: LocalizedStringKey? = nil  //Show this if there is an error
	let onComplete: (_ result: ReAuthResult) -> Void

	public var body: some View {

		VStack {

			HeroView(
				sfSymbolName: "lock.fill",
				title: "Confirm it's you.",
				subtitle: "This is a sensitive operation.\nPlease confirm your identity.",
				size: .small
			)
			.padding(.vertical, 15)

			if let error = loginErrorMessage {
				HStack {
					Text(error)
						.font(.caption)
						.foregroundStyle(.red)
					Spacer()
				}
			}

			if let user = db.currentUser {
				AppleAuthButton(showNotificationOnSuccessfulSignIn: false) {
					onComplete(.success)
				}
			} else {
				Text("Invalid State. No User Found.")
					.foregroundStyle(.red)
			}

			Button("Cancel") {
				onComplete(.canceled)
			}
			.buttonStyle(.secondary())
			.captureTaps("cancel_btn", fromView: "ReAuthView")

		}
		.padding(.bottom, 10)
	}
}
#Preview {
	ReAuthSheetView(onComplete: { _ in })
		.environmentObject(DB())
}
