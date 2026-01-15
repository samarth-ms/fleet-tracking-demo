//
//  CoreLocationService.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation
import CoreLocation

@MainActor
final class CoreLocationService: NSObject, LocationService {
    
    // MARK: - CoreLocation
    
    private let locationManager: CLLocationManager
    
    // MARK: - Authorization
    
    private(set) var authorizationStatus: LocationAuthorizationStatus = .notDetermined
    
    // MARK: - Streams
    
    let locationUpdates: AsyncStream<LocationUpdate>
    private let locationContinuation: AsyncStream<LocationUpdate>.Continuation
    
    let geoFenceEvents: AsyncStream<GeoFenceEvent>
    private let geoFenceContinuation: AsyncStream<GeoFenceEvent>.Continuation
    
    // MARK: - State
    
    private var currentConfiguration: LocationConfiguration?
    private var monitoredGeoFences: [String: GeoFence] = [:]
    
    // MARK: - Init
    
    override init() {
        self.locationManager = CLLocationManager()
        
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
        
        super.init()
        
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    // MARK: - Permissions
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - One-shot Location
    
    func getCurrentLocation() async throws -> LocationUpdate {
        try await withCheckedThrowingContinuation { continuation in
            locationManager.requestLocation()
            
            let handler = OneShotLocationHandler { result in
                switch result {
                    case .success(let location):
                        continuation.resume(
                            returning: LocationUpdate(
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude,
                                timestamp: location.timestamp,
                                accuracy: location.horizontalAccuracy
                            )
                        )
                    case .failure(let error):
                        continuation.resume(throwing: error)
                }
            }
            
            locationManager.delegate = handler
        }
    }
    
    // MARK: - Continuous Tracking
    
    func startTracking(configuration: LocationConfiguration) {
        currentConfiguration = configuration
        applyConfiguration(configuration)
        locationManager.startUpdatingLocation()
    }
    
    func updateConfiguration(_ configuration: LocationConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        applyConfiguration(configuration)
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        currentConfiguration = nil
    }
    
    private func applyConfiguration(_ configuration: LocationConfiguration) {
        locationManager.desiredAccuracy = configuration.accuracy.value
        locationManager.distanceFilter = configuration.frequency.value
        locationManager.allowsBackgroundLocationUpdates = configuration.allowsBackgroundUpdates
    }
    
    // MARK: - Geo-fencing
    
    func startMonitoring(geoFences: [GeoFence]) {
        geoFences.forEach { fence in
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(
                    latitude: fence.latitude,
                    longitude: fence.longitude
                ),
                radius: fence.radiusMeters,
                identifier: fence.id
            )
            
            region.notifyOnEntry = true
            region.notifyOnExit = true
            
            monitoredGeoFences[fence.id] = fence
            locationManager.startMonitoring(for: region)
        }
    }
    
    func stopMonitoringGeoFences() {
        locationManager.monitoredRegions.forEach {
            locationManager.stopMonitoring(for: $0)
        }
        monitoredGeoFences.removeAll()
    }
}

extension CoreLocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .notDetermined:
                authorizationStatus = .notDetermined
            case .restricted, .denied:
                authorizationStatus = .denied
            case .authorizedWhenInUse:
                authorizationStatus = .authorizedForeground
            case .authorizedAlways:
                authorizationStatus = .authorizedAlways
            @unknown default:
                break
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        
        locationContinuation.yield(
            LocationUpdate(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                timestamp: location.timestamp,
                accuracy: location.horizontalAccuracy
            )
        )
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Intentionally ignored for continuous tracking
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {
        geoFenceContinuation.yield(
            .entered(id: region.identifier, timestamp: Date())
        )
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didExitRegion region: CLRegion
    ) {
        geoFenceContinuation.yield(
            .exited(id: region.identifier, timestamp: Date())
        )
    }
}

private final class OneShotLocationHandler: NSObject, CLLocationManagerDelegate {
    
    private let completion: (Result<CLLocation, Error>) -> Void
    
    init(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        self.completion = completion
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            completion(.success(location))
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        completion(.failure(error))
    }
}
