//
//  LoginAPIModels.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

struct SendOTPRequest {
    let phoneNumber: String
}

struct SendOTPResponse {
    let success: Bool
}

struct VerifyOTPRequest {
    let phoneNumber: String
    let otp: String
}

struct VerifyOTPResponse {
    let success: Bool
    let profile: UserProfile?
}
