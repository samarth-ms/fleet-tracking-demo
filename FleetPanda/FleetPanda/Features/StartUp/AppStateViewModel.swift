//
//  AppStateViewModel.swift
//  FleetPanda
//
//  Created by Samarth on 12/01/26.
//

import Foundation
import Combine

@MainActor
final class AppStateViewModel: ObservableObject {
    
    @Published private(set) var state: AppState = .bootstrapping
    
    private let sessionStore: SessionStore
    private let userStore: UserStore
    
    init(
        sessionStore: SessionStore,
        userStore: UserStore
    ) {
        self.sessionStore = sessionStore
        self.userStore = userStore
    }
    
    func bootstrap() {
        state = sessionStore.hasActiveSession() ? .loggedIn : .loggedOut
    }
    
    func loginSucceeded(profile: UserProfile) {
        sessionStore.markLoggedIn()
        userStore.setProfile(profile)
        state = .loggedIn
    }
    
    func logout() {
        sessionStore.clearSession()
        userStore.clear()
        state = .loggedOut
    }
}
