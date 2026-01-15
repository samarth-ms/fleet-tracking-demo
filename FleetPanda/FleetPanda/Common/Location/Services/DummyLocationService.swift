//
//  DummyLocationService.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation

@MainActor
final class DummyLocationService: LocationService {
    
    // MARK: - Authorisation
    
    private(set) var authorizationStatus: LocationAuthorizationStatus = .authorizedAlways
    
    func requestPermission() {
        authorizationStatus = .authorizedAlways
    }
    
    // MARK: - Streams
    
    let locationUpdates: AsyncStream<LocationUpdate>
    private let locationContinuation: AsyncStream<LocationUpdate>.Continuation
    
    let geoFenceEvents: AsyncStream<GeoFenceEvent>
    private let geoFenceContinuation: AsyncStream<GeoFenceEvent>.Continuation
    
    // MARK: - Tracking State
    
    private(set) var currentConfiguration: LocationConfiguration?
    private var trackingTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init() {
        var locCont: AsyncStream<LocationUpdate>.Continuation!
        self.locationUpdates = AsyncStream { cont in
            locCont = cont
        }
        self.locationContinuation = locCont
        
        var geoCont: AsyncStream<GeoFenceEvent>.Continuation!
        self.geoFenceEvents = AsyncStream { cont in
            geoCont = cont
        }
        self.geoFenceContinuation = geoCont
    }
    
    // MARK: - One-shot Location
    
    func getCurrentLocation() async throws -> LocationUpdate {
        LocationUpdate(
            latitude: 12.9716,
            longitude: 77.5946,
            timestamp: Date(),
            accuracy: 10
        )
    }
    
    // MARK: - Continuous Tracking
    
    func startTracking(configuration: LocationConfiguration) {
        currentConfiguration = configuration
        restartTracking()
    }
    
    func updateConfiguration(_ configuration: LocationConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        restartTracking()
    }
    
    func stopTracking() {
        trackingTask?.cancel()
        trackingTask = nil
        currentConfiguration = nil
    }
    
    private func restartTracking() {
        trackingTask?.cancel()
        
        guard let config = currentConfiguration else { return }
        
        trackingTask = Task {
            while !Task.isCancelled {
                
                locationContinuation.yield(
                    LocationUpdate(
                        latitude: Double.random(in: 12.9...13.0),
                        longitude: Double.random(in: 77.5...77.6),
                        timestamp: Date(),
                        accuracy: config.accuracy.value
                    )
                )
                
                try? await Task.sleep(
                    nanoseconds: UInt64(config.frequency.value)
                )
            }
        }
    }
    
    // MARK: - Geo-fencing
    
    func startMonitoring(geoFences: [GeoFence]) {
        // Dummy behavior:
        // Immediately emit an "entered" event for all fences
        geoFences.forEach { fence in
            geoFenceContinuation.yield(
                .entered(id: fence.id, timestamp: Date())
            )
        }
    }
    
    func stopMonitoringGeoFences() {
        // No-op for dummy implementation
    }
}
