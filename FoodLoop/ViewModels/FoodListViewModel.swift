//
//  FoodListViewModel.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FoodListViewModel: ObservableObject {
    @Published var nearbyItems: [FoodItem] = []
    @Published var recommendedItems: [FoodItem] = []
    @Published var savedItems: [FoodItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var userLocation: Location?
    private var userPreferences: [FoodCategory]?
    
    func fetchNearbyItems() {
        // Laden von Lebensmitteln im Umkreis von 5km
    }
    
    func fetchRecommendedItems() {
        // Laden von empfohlenen Lebensmitteln basierend auf Präferenzen
    }
    
    func fetchSavedItems() {
        // Laden der gespeicherten Lebensmittel
    }
    
    func toggleSaveItem(item: FoodItem) {
        // Speichern/Entfernen eines Lebensmittels
    }
}
