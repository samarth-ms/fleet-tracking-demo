//
//  OTPInputView.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import SwiftUI

struct OTPInputView: View {
    
    let phoneNumber: String
    @State private var otp: String = ""
    let onSubmit: (String) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Verify OTP")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("OTP sent to \(phoneNumber)")
                .foregroundColor(.secondary)
            
            TextField("Enter OTP", text: $otp)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            
            Button(action: {
                onSubmit(otp)
            }) {
                Text("Verify")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(otp.isEmpty)
        }
        .padding()
    }
}
