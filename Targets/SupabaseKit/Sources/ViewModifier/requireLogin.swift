//
//  requireLogin.swift
//  SupabaseKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/authkit/lock-views-behind-auth
//

import SharedKit
import SwiftUI

extension View {
	/// This modifier makes sure that the view that it is applied to will only be shown if the user is logged in.
	/// - Parameters:
	///   - db: Pass the state of the Database.
	///   - navTitle (optional): The title of the navigation bar when the user is prompted to sign in.
	///   - onCancel: A button will be shown in the top left corner, that will let the user close the Sign In. Use this to close the View that requires the user to be logged in.
	public func requireLogin(
		db: DB,
		navTitle: LocalizedStringKey = "",
		onCancel: @escaping () -> Void
	) -> some View {
		modifier(
			RequireLoginViewModifier(
				db: db,
				navTitle: navTitle,
				onCancel: onCancel
			)
		)
	}
}

private struct RequireLoginViewModifier: ViewModifier {

	@ObservedObject var db: DB
	@State var showSheet: Bool

	// NavTitle for the user to understand what is behind the Login View (For Example, Account Info)
	let navTitle: LocalizedStringKey
	let onCancel: () -> Void

	init(
		db: DB,
		navTitle: LocalizedStringKey,
		onCancel: @escaping () -> Void
	) {
		self.db = db
		self.showSheet = db.authState != .signedIn
		self.navTitle = navTitle
		self.onCancel = onCancel
	}

	func body(content: Content) -> some View {

		// User logged in -> see content
		// User not logged in -> show hero view and display sheet
		Group {
			if db.authState == .signedIn {
				content
			} else {
				VStack {
					HeroView(
						sfSymbolName: "person", title: "Account Required.",
						subtitle: "You must be signed in to view this content."
					)
					.padding(.top, -10)
					Button("Sign In") {
						showSheet = true
					}
					.padding(.top, 10)
				}
			}
		}
		.sheet(
			isPresented: $showSheet,
			onDismiss: {
				Task {
					if db.authState == .signedOut {
						try? await Task.sleep(for: .seconds(0.15))
						onCancel()
					}
				}
			}
		) {
			SignInView(
				db: db,
				navTitle: navTitle,
				onSignedIn: {
					showSheet = false
				}
			)
			.presentationDetents([.height(400)])
			.presentationCornerRadius(35)
		}
	}
}
