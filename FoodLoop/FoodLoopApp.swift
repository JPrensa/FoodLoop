//
//  FoodLoopApp.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 18.02.25.
//

import SwiftUI
import FirebaseCore


@main
struct Code_SnippetsApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isUserLoggedIn {
                MainView()
            } else {
            
               AuthView(authViewModel: authViewModel)
            }
        }
    }
}
