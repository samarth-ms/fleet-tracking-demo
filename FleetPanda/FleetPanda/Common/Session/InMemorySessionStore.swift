//
//  InMemorySessionStore.swift
//  FleetPanda
//
//  Created by Samarth on 12/01/26.
//

final class InMemorySessionStore: SessionStore {
    
    private var isLoggedIn: Bool = false
    
    func hasActiveSession() -> Bool {
        isLoggedIn
    }
    
    func clearSession() {
        isLoggedIn = false
    }
    
    func markLoggedIn() {
        isLoggedIn = true
    }
}
