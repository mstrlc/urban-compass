//
//  LocationUtils.swift
//  urbancompass
//
//  Created by Matyáš Strelec on 29.04.2025.
//

import CoreLocation

enum LocationUtils {
    static func formattedDistance(from origin: CLLocationCoordinate2D?, to destination: CLLocationCoordinate2D?) -> String {
        guard let origin = origin, let destination = destination else {
            return ""
        }

        let location1 = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
        let location2 = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        let distanceInMeters = location1.distance(from: location2)

        if distanceInMeters < 1000 {
            return String(format: "%.0f m", distanceInMeters)
        } else {
            return String(format: "%.1f km", distanceInMeters / 1000)
        }
    }
}
