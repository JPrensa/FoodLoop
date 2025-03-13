//
//  FoodUploadViewModel.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FoodUploadViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var selectedCategory: FoodCategory?
    @Published var image: UIImage?
    @Published var expiryDate: Date?
    @Published var availableTimes: [AvailableTimeSlot] = []
    @Published var categories: [FoodCategory] = []
    @Published var isUploading = false
    @Published var errorMessage: String?
    
    func fetchCategories() {
        // Laden der Kategorien von der API
    }
    
    func uploadFoodItem() {
        // Hochladen eines neuen Lebensmittels
    }
}
