//
//  AssignedShiftView.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import SwiftUI

struct AssignedShiftView: View {
    
    let onStartShift: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Shift Assigned")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("You must be at the hub to start your shift")
                .foregroundColor(.secondary)
            
            Button("Start Shift") {
                onStartShift()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
