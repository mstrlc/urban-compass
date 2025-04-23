//
//  AttractionMapView.swift
//  urbancompass
//
//  Created by Matyáš Strelec on 19.04.2025.
//

import SwiftUI
import MapKit

struct AttractionMapView: View {
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.1951, longitude: 16.6068),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
        
    var body: some View {
        Map(position: $cameraPosition).mapStyle(.standard(pointsOfInterest: .excludingAll))
    }
}

#Preview {
    AttractionMapView()
}
