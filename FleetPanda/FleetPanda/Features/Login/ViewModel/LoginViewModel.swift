//
//  LoginViewModel.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: LoginViewModelProtocol {
    
    @Published private(set) var state: LoginState = .enterPhone
    
    private let network: NetworkClient
    private let appStateVM: AppStateViewModel
    
    init(
        network: NetworkClient,
        appStateVM: AppStateViewModel
    ) {
        self.network = network
        self.appStateVM = appStateVM
    }
    
    func submitPhone(_ phone: String) {
        state = .loading
        
        Task {
            do {
                let response: SendOTPResponse = try await network.send(
                    SendOTPRequest(phoneNumber: phone)
                )
                
                if response.success {
                    state = .enterOTP(phoneNumber: phone)
                } else {
                    // Business failure (e.g. user not found)
                    state = .enterPhone
                }
                
            } catch {
                // Transport failure only
                state = .error("Network error. Please try again.")
            }
        }
    }
    
    func submitOTP(phone: String, otp: String) {
        state = .loading
        
        Task {
            do {
                let response: VerifyOTPResponse = try await network.send(
                    VerifyOTPRequest(phoneNumber: phone, otp: otp)
                )
                
                if response.success, let profile = response.profile {
                    appStateVM.loginSucceeded(profile: profile)
                } else {
                    // Business failure: invalid OTP
                    state = .enterOTP(phoneNumber: phone)
                }
                
            } catch {
                // Transport failure only
                state = .error("Network error. Please try again.")
            }
        }
    }
    
    func reset() {
        state = .enterPhone
    }
}
