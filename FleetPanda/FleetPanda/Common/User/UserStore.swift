//
//  UserStore.swift
//  FleetPanda
//
//  Created by Samarth on 12/01/26.
//

import Foundation
import Combine

final class UserStore: ObservableObject {
    @Published private(set) var profile: UserProfile?
    
    func setProfile(_ profile: UserProfile) {
        self.profile = profile
    }
    
    func clear() {
        self.profile = nil
    }
}
