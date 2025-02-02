//
//  ProfileImage.swift
//  SharedKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/sharedkit/ui#profile-image-component
//

import SwiftUI

public struct ProfileImage: View {

	private let url: URL?
	private let width: CGFloat

	public init(url: URL?, width: CGFloat) {
		self.url = url
		self.width = width
	}

	public var body: some View {
		if let url {
			AsyncImage(url: url) { image in
				image
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: width, height: width)
					.clipShape(Circle())

			} placeholder: {
				EmptyProfilePic(width: width)
			}

		} else {
			EmptyProfilePic(width: width)
		}
	}

	struct EmptyProfilePic: View {
		let width: CGFloat
		public var body: some View {
			Image(systemName: "person.fill")
				.font(.system(size: width / 2))
				.foregroundStyle(Color.white)
				.frame(width: width, height: width)
				.background(Color.gray.gradient)
				.clipShape(Circle())
		}
	}

}
