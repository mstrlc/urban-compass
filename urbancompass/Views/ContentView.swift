//
//  ContentView.swift
//  urbancompass
//
//  Created by Matyáš Strelec on 19.04.2025.
//

import SwiftUI

enum ScreensEnum {
    case list, map
}

struct ContentView: View {
    @State var currentScreen: ScreensEnum = .list
    
    var body: some View {
        
        TabView(selection: $currentScreen) {
            
            AttractionListView()
                .tag(ScreensEnum.list)
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet")
                        Text("List")
                    }
                }
            
            AttractionMapView()
                .tag(ScreensEnum.map)
                .tabItem {
                    VStack {
                        Image(systemName: "map")
                        Text("Map")
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
