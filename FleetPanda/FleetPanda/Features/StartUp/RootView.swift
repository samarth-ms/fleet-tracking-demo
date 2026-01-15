//
//  RootView.swift
//  FleetPanda
//
//  Created by Samarth on 12/01/26.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject private var appStateVM: AppStateViewModel
    
    var body: some View {
        switch appStateVM.state {
            case .bootstrapping:
                ProgressView() // Splash screen
                
            case .loggedOut:
                LoginRootView(
                    viewModel: LoginViewModel(
                        network: FakeNetworkClient(),
                        appStateVM: appStateVM
                    )
                )
                
            case .loggedIn:
                ShiftGateView(
                    viewModel: ShiftLifecycleViewModel(
                        locationService: DummyLocationService()
                    )
                )
        }
    }
}


struct MainAppPlaceholderView: View {
    var body: some View {
        Text("Main App")
    }
}
