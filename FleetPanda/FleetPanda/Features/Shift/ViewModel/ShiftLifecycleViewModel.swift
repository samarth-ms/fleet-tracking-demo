//
//  ShiftLifecycleViewModel.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation
import Combine

@MainActor
final class ShiftLifecycleViewModel: ObservableObject {
    
    
    @Published private(set) var state: ShiftLifecycleState = .resolving
    
    private let locationService: LocationService
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    // MARK: - Bootstrap
    
    func resolveShift() {
        // Dummy resolution for now
        let resolution = 3
        switch resolution {
            case 1: let assignedShift = Shift(
                        id: "shift_001",
                        type: .regular,
                        scheduledStart: Date(),
                        scheduledEnd: Date().addingTimeInterval(8 * 60 * 60),
                        actualStart: nil,
                        actualEnd: nil,
                        status: .assigned
                    )
                    state = .assigned(assignedShift)
            case 2: let assignedShift = Shift(
                        id: "shift_001",
                        type: .regular,
                        scheduledStart: Date().addingTimeInterval(-2 * 60 * 60),
                        scheduledEnd: Date().addingTimeInterval(6 * 60 * 60),
                        actualStart: nil,
                        actualEnd: nil,
                        status: .assigned
                    )
                    state = .active(assignedShift)
                
            case 3: state = .noShift
                
            default: break

        }
    }
    
    // MARK: - Activation
    
    func startShift() {
        guard case .assigned(var shift) = state else { return }
        
        Task {
            do {
                _ = try await locationService.getCurrentLocation()
                // Hub proximity validation plugs in here
                
                shift.actualStart = Date()
                shift.status = .active
                
                state = .active(shift)
                
            } catch {
                // Stay in assigned state; UI shows error
            }
        }
    }
    
    // MARK: - End Shift (future)
    
    func endShift() {
        guard case .active(var shift) = state else { return }
        
        shift.actualEnd = Date()
        shift.status = .ended
        
        state = .noShift
    }
}
