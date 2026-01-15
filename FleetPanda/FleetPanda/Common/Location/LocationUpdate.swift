//
//  LocationUpdate.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation

struct LocationUpdate: Equatable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let accuracy: Double
}
