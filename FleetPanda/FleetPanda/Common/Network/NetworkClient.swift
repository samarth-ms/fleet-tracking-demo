//
//  NetworkClient.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

protocol NetworkClient {
    func send<Request, Response>(_ request: Request) async throws -> Response
    func send<Request, Response>(_ request: Request, delay: UInt64) async throws -> Response
}
