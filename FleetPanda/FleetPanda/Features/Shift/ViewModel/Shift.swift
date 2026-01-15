//
//  Shift.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation

enum ShiftType: Equatable {
    case regular
    case adhoc
}

enum ShiftStatus: Equatable {
    case assigned
    case active
    case ended
}

struct Shift: Equatable {
    let id: String
    let type: ShiftType
    
    let scheduledStart: Date
    let scheduledEnd: Date
    
    var actualStart: Date?
    var actualEnd: Date?
    
    var status: ShiftStatus
}
