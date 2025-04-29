//
//  AttractionDetailView.swift
//  urbancompass
//
//  Created by Matyáš Strelec on 22.04.2025.
//

import CoreLocation
import Foundation
import SwiftUI

struct AttractionDetailView: View {
    let attributes: Attributes

    @State private var isTextExpanded: Bool = false
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var distanceToAttraction: String = ""

    var body: some View {
        ScrollView {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading) {
                    Text(attributes.name ?? "Attraction")
                        .font(.title)
                        .fontWeight(.heavy)
                    if attributes.street != nil || attributes.city != nil {
                        Text("\(attributes.street ?? ""), \(attributes.city ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if let latitude = attributes.latitude, let longitude = attributes.longitude {
                    Link(destination: URL(string: "maps:0,0?q=\(latitude),\(longitude)")!) {
                        if !distanceToAttraction.isEmpty {
                            Text("\(distanceToAttraction)")
                                .font(.subheadline)
                        }
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding([.leading, .trailing], 20)

            VStack(alignment: .leading, spacing: 16) {
                if let imageURL = attributes.image, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.1)
                                ProgressView()
                            }
                            .cornerRadius(12)
                            .frame(height: 150)
                        case let .success(image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                        case .failure:
                            ZStack {
                                Color.gray.opacity(0.1)
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.secondary)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    if let text = attributes.text {
                        Text(text)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(isTextExpanded ? nil : 3)
                            .padding(.top, 8)

                        Button(action: {
                            isTextExpanded.toggle()
                        }) {
                            HStack {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.accentColor)
                                Text(isTextExpanded ? "Show Less" : "Show More")
                                    .font(.body)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }

                    if let urlString = attributes.url, let url = URL(string: urlString) {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.accentColor)
                                Text(urlString)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.top, 8)
                    }

                    if let email = attributes.email {
                        Link(destination: URL(string: "mailto:\(email)")!) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.accentColor)
                                Text(email)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.top, 8)
                    }

                    if let phone = attributes.phone {
                        Link(destination: URL(string: "tel:\(phone)")!) {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.accentColor)
                                Text(phone)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .onAppear {
            requestLocationAndCalculateDistance()
        }
        .onChange(of: attributes) {
            requestLocationAndCalculateDistance()
        }
    }

    // Function to request the user's location and calculate the distance to the attraction
    func requestLocationAndCalculateDistance() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        if let location = locationManager.location {
            userLocation = location.coordinate
            distanceToAttraction = LocationUtils.formattedDistance(
                from: location.coordinate,
                to: attributes.coordinate
            )
        }
    }
}

#Preview {
    AttractionMapView()
}
