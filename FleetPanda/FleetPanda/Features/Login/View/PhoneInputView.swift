//
//  PhoneInputView.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import SwiftUI

struct PhoneInputView: View {
    
    @State private var phoneNumber: String = ""
    let onSubmit: (String) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Phone Number", text: $phoneNumber)
                .keyboardType(.phonePad)
                .textFieldStyle(.roundedBorder)
            
            Button(action: {
                onSubmit(phoneNumber)
            }) {
                Text("Send OTP")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(phoneNumber.isEmpty)
        }
        .padding(.horizontal, 40)
    }
}
