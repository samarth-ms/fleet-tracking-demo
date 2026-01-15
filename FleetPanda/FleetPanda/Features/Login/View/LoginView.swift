//
//  LoginView.swift
//  FleetPanda
//
//  Created by Samarth on 11/01/26.
//

import SwiftUI

struct LoginRootView<VM: LoginViewModelProtocol>: View {
    
    @StateObject var viewModel: VM
    
    var body: some View {
        Group {
            switch viewModel.state {
                case .enterPhone:
                    PhoneInputView(
                        onSubmit: viewModel.submitPhone
                    )
                    
                case .enterOTP(let phoneNumber):
                    OTPInputView(
                        phoneNumber: phoneNumber,
                        onSubmit: { otp in
                            viewModel.submitOTP(
                                phone: phoneNumber,
                                otp: otp
                            )
                        }
                    )
                    
                case .loading:
                    LoadingView()
                    
                case .error(let message):
                    ErrorView(
                        message: message,
                        onRetry: {
                            viewModel.reset()
                        }
                    )
            }
        }
        .animation(.easeInOut, value: viewModel.state)
    }
}
