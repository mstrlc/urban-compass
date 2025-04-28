//
//  Item.swift
//  urbancompass
//
//  Created by Matyáš Strelec on 23.04.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
