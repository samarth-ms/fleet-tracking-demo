//
//  FleetPandaApp.swift
//  FleetPanda
//
//  Created by Samarth on 11/01/26.
//

import SwiftUI
import SwiftData

@main
struct FleetPandaApp: App {
    
    private let sessionStore: SessionStore
    private let userStore: UserStore
    
    @StateObject private var appStateVM: AppStateViewModel

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        let sessionStore = InMemorySessionStore()
        let userStore = UserStore()
        
        self.sessionStore = sessionStore
        self.userStore = userStore
        
        _appStateVM = StateObject(
            wrappedValue: AppStateViewModel(
                sessionStore: sessionStore,
                userStore: userStore
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appStateVM)
                .environmentObject(userStore)
                .onAppear {
                    appStateVM.bootstrap()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
