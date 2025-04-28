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
    @State private var userLocation: CLLocation?
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
                            Text(isTextExpanded ? "Show Less" : "Show More")
                                .font(.body)
                                .foregroundColor(.accentColor)
                        }
                    }

                    if let urlString = attributes.url, let url = URL(string: urlString) {
                        Link(destination: url) {
                            Text("Visit Website")
                                .font(.body)
                                .foregroundColor(.accentColor)
                        }
                        .padding(.top, 8)
                    }

                    if let latitude = attributes.latitude, let longitude = attributes.longitude {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Latitude: \(latitude)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Longitude: \(longitude)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .onAppear {
            fetchUserLocation()
        }
        .onChange(of: attributes) {
            fetchUserLocation()
        }
    }

    func fetchUserLocation() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        if let userLocation = locationManager.location {
            self.userLocation = userLocation
            calculateDistance()
        }
    }

    func calculateDistance() {
        if let userLocation = userLocation,
           let latitude = attributes.latitude,
           let longitude = attributes.longitude
        {
            let attractionLocation = CLLocation(latitude: latitude, longitude: longitude)
            let distanceInMeters = userLocation.distance(from: attractionLocation)
            let distanceInKilometers = distanceInMeters / 1000 // convert to kilometers
            distanceToAttraction = String(format: "%.2f km", distanceInKilometers)
        }
    }
}

#Preview {
    AttractionMapView()
}
