//
//  ContentView.swift
//  urbancompass
//
//  Created by Matyáš Strelec on 19.04.2025.
//

import Foundation
import SwiftUI

struct ContentView: View {
    var body: some View {
        AttractionMapView()
            .accentColor(.orange)
            .tint(.orange)
    }
}

#Preview {
    ContentView()
}
