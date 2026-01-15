//
//  LoadingView.swift
//  FleetPanda
//
//  Created by Samarth on 13/01/26.
//

import SwiftUI

struct LoadingView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Please wait…")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
