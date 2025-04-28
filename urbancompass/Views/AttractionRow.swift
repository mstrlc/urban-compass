//
//  AttractionRow.swift
//  urbancompass
//
//  Created by Matyáš Strelec on 22.04.2025.
//

import Foundation
import SwiftUI

struct AttractionRow: View {
    let attributes: Attributes
    private let rowHeight: CGFloat = 60

    var body: some View {
        HStack(spacing: 12) {
            if let imageUrl = attributes.image, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.1)
                            ProgressView()
                        }

                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure:
                        placeholderImage

                    @unknown default:
                        placeholderImage
                    }
                }
                .frame(width: rowHeight, height: rowHeight)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                placeholderImage
                    .frame(width: rowHeight, height: rowHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(attributes.name ?? "Name not available")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(attributes.street != nil || attributes.city != nil
                    ? "\(attributes.street ?? ""), \(attributes.city ?? "")"
                    : (attributes.text ?? ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
    }

    private var placeholderImage: some View {
        ZStack {
            Color.gray.opacity(0.1)
            Image(systemName: "photo.fill")
                .resizable()
                .scaledToFit()
                .frame(width: rowHeight * 0.6, height: rowHeight * 0.6)
                .foregroundColor(.secondary)
        }
    }
}
