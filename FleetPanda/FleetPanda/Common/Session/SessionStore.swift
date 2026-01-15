//
//  SessionStore.swift
//  FleetPanda
//
//  Created by Samarth on 12/01/26.
//

protocol SessionStore {
    func hasActiveSession() -> Bool
    func markLoggedIn()
    func clearSession()
}
