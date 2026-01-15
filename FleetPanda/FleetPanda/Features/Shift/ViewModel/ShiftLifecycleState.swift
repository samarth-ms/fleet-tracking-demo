//
//  ShiftLifecycleState.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation

enum ShiftLifecycleState: Equatable {
    case resolving
    case noShift
    case assigned(Shift)
    case active(Shift)
}
