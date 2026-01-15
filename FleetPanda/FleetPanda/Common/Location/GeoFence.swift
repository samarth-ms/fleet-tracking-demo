//
//  GeoFence.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation

struct GeoFence: Equatable {
    let id: String
    let latitude: Double
    let longitude: Double
    let radiusMeters: Double
}

enum GeoFenceEvent: Equatable {
    case entered(id: String, timestamp: Date)
    case exited(id: String, timestamp: Date)
}
