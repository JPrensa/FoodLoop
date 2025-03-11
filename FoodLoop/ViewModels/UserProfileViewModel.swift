//
//  UserProfileViewModel.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//


class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var foodsSaved = 0
    @Published var userRating: Double?
    @Published var isDarkMode = false
    
    func fetchUserProfile() {
        // Laden des Nutzerprofils
    }
    
    func updateUserPreferences(_ preferences: [FoodCategory]) {
        // Aktualisieren der Nutzerpräferenzen
    }
    
    func toggleDarkMode() {
        // Umschalten des Dark Mode
    }
    
    func calculateUserStats() {
        // Berechnen der Nutzerstatistiken
    }
}