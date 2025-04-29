//
//  AttractionMapView.swift
//  urbancompass
//
//  Created by Matyáš Strelec on 22.04.2025.
//

import CoreLocation
import Foundation
import MapKit
import SwiftUI

// Calculate distance between two coordinates
func distanceBetween(_ coordinate1: CLLocationCoordinate2D, _ coordinate2: CLLocationCoordinate2D) -> CLLocationDistance {
    let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
    let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
    return location1.distance(from: location2)
}

// Custom annotation view for displaying attraction pins on the map
struct MapAnnotationView: View {
    let isActive: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(.orange)
                .frame(width: isActive ? 36 : 24, height: isActive ? 36 : 24)
                .shadow(radius: 5)

            Image(systemName: "mappin")
                .foregroundColor(.white)
                .font(.system(size: isActive ? 20 : 14))
        }
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

struct AttractionMapView: View {
    @StateObject private var viewModel = AttractionMapViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.1951, longitude: 16.6068),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    @State private var filterHasLocation: FilterLocation = .both
    @State private var sortOrder: SortOrder = .distance

    enum SortOrder {
        case defaultOrder, name, distance
    }

    enum FilterLocation {
        case both, withLocation, withoutLocation
    }

    // Select and zoom to a random attraction
    func pickRandomAttraction() {
        if let randomAttraction = viewModel.attractions.randomElement() {
            viewModel.activeAttraction = randomAttraction
            if let coordinate = randomAttraction.coordinate {
                withAnimation(.easeInOut(duration: 1)) {
                    cameraPosition = .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                }
            }
        }
    }

    var body: some View {
        ZStack {
            Map(position: $cameraPosition, selection: $viewModel.activeAttraction) {
                ForEach(viewModel.mapAttractions) { attraction in
                    if let coordinate = attraction.coordinate {
                        Annotation(attraction.name ?? "Attraction", coordinate: coordinate) {
                            MapAnnotationView(isActive: viewModel.activeAttraction == attraction)
                        }
                        .tag(attraction)
                    }
                }
                UserAnnotation()
            }
            .mapControls {
                MapScaleView()
                MapCompass()
                MapPitchToggle()
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))

            if let errorMsg = viewModel.errorMessage, !viewModel.isLoading {
                VStack {
                    Spacer()
                    Text("Error: \(errorMsg)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                        .foregroundColor(.red)
                        .lineLimit(nil)
                }
            }
        }
        .sheet(isPresented: .constant(true), onDismiss: {
            viewModel.selectedDetent = .fraction(0.3)
        }) {
            NavigationStack(path: $viewModel.navigationPath) {
                VStack {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "map")
                            .font(.title2)
                            .foregroundColor(.orange)

                        Text("Attractions")
                            .font(.title)
                            .fontWeight(.heavy)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        Button(action: pickRandomAttraction) {
                            Image(systemName: "shuffle")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding([.top, .leading, .trailing], 20)

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Loading")
                        Spacer()
                    } else if viewModel.attractions.isEmpty && viewModel.errorMessage == nil {
                        Spacer()
                        Text("No attractions found.")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else if !viewModel.attractions.isEmpty {
                        List {
                            ForEach(viewModel.attractions) { attractionAttributes in
                                NavigationLink(value: attractionAttributes) {
                                    AttractionRow(attributes: attractionAttributes)
                                        .listRowBackground(viewModel.activeAttraction == attractionAttributes ? Color.gray.opacity(0.3) : nil)
                                }
                            }
                        }
                        .listStyle(.inset)
                        .navigationDestination(for: Attributes.self) { attraction in
                            AttractionDetailView(attributes: attraction)
                        }
                    } else {
                        Spacer()
                        Text("Could not load attractions.")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .presentationBackgroundInteraction(.enabled)
            .interactiveDismissDisabled()
            .presentationDetents([.fraction(0.3), .fraction(0.5), .fraction(0.99)], selection: $viewModel.selectedDetent)
            .onAppear {
                if viewModel.attractions.isEmpty && !viewModel.isLoading {
                    viewModel.fetchData()
                }
            }
            .onChange(of: viewModel.navigationPath) { _, newValue in
                viewModel.syncSelectionFromNavigation(newPath: newValue)
                viewModel.selectedDetent = .fraction(0.3)
            }
        }
        .onChange(of: viewModel.activeAttraction) { _, newValue in
            viewModel.syncNavigationAndSelection(newActive: newValue)
            viewModel.selectedDetent = .fraction(0.3)
            if let selected = newValue, let coordinate = selected.coordinate {
                print("Sync: Moving map camera to \(selected.name ?? "N/A")")
                withAnimation(.easeInOut(duration: 1)) {
                    cameraPosition = .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                }
            }
        }
        .onAppear {
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
    }
}

#Preview {
    AttractionMapView()
}
