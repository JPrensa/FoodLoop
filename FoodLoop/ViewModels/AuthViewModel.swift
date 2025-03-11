//
//  AuthViewModel.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//


class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    func signInAnonymously() {
        // Firebase Anonyme Anmeldung
    }
    
    func signInWithGoogle() {
        // Firebase Google Anmeldung
    }
    
    func signOut() {
        // Abmelden
    }
    
    func updateUserProfile(_ updatedUser: User) {
        // Aktualisieren des Nutzerprofils
    }
}