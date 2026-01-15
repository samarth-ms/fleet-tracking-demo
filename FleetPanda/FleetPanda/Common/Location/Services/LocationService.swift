//
//  LocationService.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation

@MainActor
protocol LocationService {
    
    // Permissions
    var authorizationStatus: LocationAuthorizationStatus { get }
    func requestPermission()
    
    // One-shot
    func getCurrentLocation() async throws -> LocationUpdate
    
    // Continuous tracking
    func startTracking(configuration: LocationConfiguration)
    func updateConfiguration(_ configuration: LocationConfiguration)
    func stopTracking()
    var locationUpdates: AsyncStream<LocationUpdate> { get }
    
    // Geo-fencing
    func startMonitoring(geoFences: [GeoFence])
    func stopMonitoringGeoFences()
    var geoFenceEvents: AsyncStream<GeoFenceEvent> { get }
}
