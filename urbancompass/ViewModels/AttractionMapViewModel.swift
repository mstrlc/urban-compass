//
//  AttractionMapViewModel.swift
//  urbancompass
//
//  Created by Matyáš Strelec on 22.04.2025.
//

import Foundation
import MapKit
import SwiftUI

@MainActor
class AttractionMapViewModel: ObservableObject {
    @Published var attractions: [Attributes] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var activeAttraction: Attributes? = nil
    @Published var navigationPath: [Attributes] = []
    @Published var selectedDetent: PresentationDetent = .fraction(0.3)

    // URL to fetch the attraction data from a remote service (ArcGIS API).
    private let attractionsURLString = "https://services6.arcgis.com/fUWVlHWZNxUvTUh8/arcgis/rest/services/PLACES/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"

    // A computed property that filters attractions to only those with valid coordinates.
    var mapAttractions: [Attributes] {
        attractions.filter { $0.coordinate != nil }
    }

    // Function to fetch data from the URL and update the attractions list.
    func fetchData() {
        guard let url = URL(string: attractionsURLString) else {
            errorMessage = "Invalid API URL"
            return
        }

        isLoading = true
        errorMessage = nil

        // Call the custom `fetchAttractions` function from `URLSession` extension.
        URLSession.shared.fetchAttractions(at: url) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case let .success(fetchedAttributes):
                    self.attractions = fetchedAttributes
                    if fetchedAttributes.isEmpty {
                        self.errorMessage = "Successfully loaded but no attractions were returned"
                    }
                case let .failure(error):
                    if let decodingError = error as? DecodingError {
                        self.errorMessage = "Data Parsing Error:\n\(decodingError)"
                    } else {
                        self.errorMessage = "Failed to fetch features: \(error.localizedDescription)"
                    }
                    self.attractions = []
                }
            }
        }
    }

    // Function to synchronize the navigation path and active selection.
    func syncNavigationAndSelection(newActive: Attributes?) {
        let newPath = (newActive != nil) ? [newActive!] : []
        if navigationPath != newPath {
            navigationPath = newPath
        }
    }

    // Function to synchronize the selection based on the current navigation path.
    func syncSelectionFromNavigation(newPath: [Attributes]) {
        let lastPathElement = newPath.last
        if activeAttraction != lastPathElement {
            activeAttraction = lastPathElement
        }
    }
}
