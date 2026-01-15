//
//  LoginState.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

enum LoginState: Equatable {
    case enterPhone
    case enterOTP(phoneNumber: String)
    case loading
    case error(String)   // used ONLY for network-level issues
}
