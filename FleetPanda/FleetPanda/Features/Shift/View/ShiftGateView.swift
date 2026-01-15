//
//  ShiftGateView.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import SwiftUI

struct ShiftGateView: View {
    
    @StateObject var viewModel: ShiftLifecycleViewModel
    
    var body: some View {
        switch viewModel.state {
                
            case .resolving:
                ProgressView()
                    .onAppear {
                        viewModel.resolveShift()
                    }
                
            case .noShift:
                Text("No shift assigned")
                
            case .assigned:
                AssignedShiftView(
                    onStartShift: {
                        viewModel.startShift()
                    }
                )
                
            case .active:
                Text("Shift Active – Operational Flow")
        }
    }
}
