//
//  LoginViewModelProtocol.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation

@MainActor
protocol LoginViewModelProtocol: ObservableObject {
    var state: LoginState { get }
    
    func submitPhone(_ phone: String)
    func submitOTP(phone: String, otp: String)
    func reset()
}
