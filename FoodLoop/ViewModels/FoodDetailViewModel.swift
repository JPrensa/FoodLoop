//
//  FoodDetailViewModel.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FoodDetailViewModel: ObservableObject {
    @Published var foodItem: FoodItem?
    @Published var owner: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchFoodItem(id: String) {
        // Laden eines bestimmten Lebensmittels
    }
    
    func fetchOwner() {
        // Laden des Besitzers
    }
    
    func submitRating(stars: Double, comment: String?) {
        // Bewertung abgeben
    }
}
