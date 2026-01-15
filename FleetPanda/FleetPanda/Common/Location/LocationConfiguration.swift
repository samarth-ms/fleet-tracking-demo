//
//  LocationConfiguration.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation
import CoreLocation

struct LocationConfiguration: Equatable {
    let accuracy: LocationAccuracy
    let frequency: LocationFrequency
    let allowsBackgroundUpdates: Bool
}

enum LocationAccuracy {
    case low
    case medium
    case high
    
    var value: CLLocationAccuracy {
        switch self {
            case .low:    return kCLLocationAccuracyKilometer     // kCLLocationAccuracyHundredMeters
            case .medium: return kCLLocationAccuracyHundredMeters // kCLLocationAccuracyNearestTenMeters
            case .high:   return kCLLocationAccuracyBest
        }
    }
}

enum LocationFrequency {
    case low
    case medium
    case high
    
    var distanceFilter: CLLocationDistance {
        switch self {
            case .low:    return 1000.0   // 1 km
            case .medium: return 200.0    // 200 m
            case .high:   return 50.0     // 50 m
        }
    }
    
    var value: Double {
        switch self {
            case .low:    return 500
            case .medium: return 50
            case .high:   return 10
        }
    }
}
