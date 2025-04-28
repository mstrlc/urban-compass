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

    private let attractionsURLString = "https://services6.arcgis.com/fUWVlHWZNxUvTUh8/arcgis/rest/services/PLACES/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"

    var mapAttractions: [Attributes] {
        attractions.filter { $0.coordinate != nil }
    }

    func fetchData() {
        guard let url = URL(string: attractionsURLString) else {
            errorMessage = "Invalid API URL"
            return
        }

        isLoading = true
        errorMessage = nil

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

    func syncNavigationAndSelection(newActive: Attributes?) {
        let newPath = (newActive != nil) ? [newActive!] : []
        if navigationPath != newPath {
            navigationPath = newPath
        }
    }

    func syncSelectionFromNavigation(newPath: [Attributes]) {
        let lastPathElement = newPath.last
        if activeAttraction != lastPathElement {
            activeAttraction = lastPathElement
        }
    }
}
