//
//  SocotoApp.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import SwiftUI

@main
struct SocotoApp: App {
    init() {
        // Validate configuration on app launch
        let missingKeys = Config.validateConfiguration()
        if !missingKeys.isEmpty {
            print("⚠️ Warning: Missing configuration keys: \(missingKeys.joined(separator: ", "))")
        }
    }

    var body: some Scene {
        WindowGroup {
            TabBarView()
                .preferredColorScheme(.dark) // Force dark mode for glassmorphism effect
        }
    }
}
