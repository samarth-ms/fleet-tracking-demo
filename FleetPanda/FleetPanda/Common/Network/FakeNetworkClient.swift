//
//  FakeNetworkClient.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import Foundation

final class FakeNetworkClient: NetworkClient {
    
    private let scenario: NetworkScenario
    
    init(scenario: NetworkScenario = .default) {
        self.scenario = scenario
    }
    
    func send<Request, Response>(_ request: Request) async throws -> Response {
        return try await send(request, delay: 1_000_000_000)
    }
    
    func send<Request, Response>(_ request: Request, delay: UInt64 = 1_000_000_000) async throws -> Response {
        
        try await Task.sleep(nanoseconds: delay)
        
        if scenario == .networkFailure {
            throw NSError(domain: "FakeNetwork", code: -1009)
        }
        
        guard let response = responseForScenario(request) as? Response else {
            throw NSError(domain: "FakeNetwork", code: -1)
        }
        
        return response
    }
}
    
private extension FakeNetworkClient {
    
    func responseForScenario<Request>(_ request: Request) -> Any {
        switch scenario {
                
            case .default:
                return defaultResponse(for: request)
                
            case .invalidOTP:
                return invalidOTPResponse(for: request)
                ?? defaultResponse(for: request)
                
            case .userNotFound:
                return userNotFoundResponse(for: request)
                ?? defaultResponse(for: request)
                
            case .networkFailure:
                fatalError("Handled earlier")
        }
    }
    
    func defaultResponse<Request>(for request: Request) -> Any {
        switch request {
                
            case is SendOTPRequest:
                return SendOTPResponse(success: true)
                
            case is VerifyOTPRequest:
                return VerifyOTPResponse(
                    success: true,
                    profile: UserProfile(
                        userId: "driver_123",
                        phoneNumber: "9999999999",
                        name: "Demo Driver"
                    )
                )
                
            default:
                fatalError("No default mock for request \(Request.self)")
        }
    }
}

private extension FakeNetworkClient {
    
    func invalidOTPResponse<Request>(for request: Request) -> Any? {
        switch request {
            case is VerifyOTPRequest:
                return VerifyOTPResponse(success: false, profile: nil)
            default:
                return defaultResponse(for: request)
        }
    }
    
    func userNotFoundResponse<Request>(for request: Request) -> Any? {
        switch request {
            case is SendOTPRequest:
                return SendOTPResponse(success: false)
            default:
                return defaultResponse(for: request)
        }
    }
}
