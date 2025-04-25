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
    
    private let db = Firestore.firestore()
       private var userLocation: Location?
       private var userPreferences: [FoodCategory]?
       
       func setUserLocation(_ location: Location) {
           self.userLocation = location
       }
       
       func setUserPreferences(_ preferences: [FoodCategory]?) {
           self.userPreferences = preferences
       }
       
       
       func fetchNearbyItems() {
           
           isLoading = true
           
           db.collection("foodItems")
               .whereField("isAvailable", isEqualTo: true)
               .order(by: "createdAt", descending: true)
               .limit(to: 10)
               .getDocuments { [weak self] snapshot, error in
                   DispatchQueue.main.async {
                       self?.isLoading = false
                       
                       if let error = error {
                           self?.errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
                           return
                       }
                       
                       guard let documents = snapshot?.documents else {
                           self?.nearbyItems = []
                           return
                       }
                       
                       let items = documents.compactMap { document -> FoodItem? in
                           try? document.data(as: FoodItem.self)
                       }
                       
                       self?.nearbyItems = items
                   }
               }
       }
       
       
       func fetchRecommendedItems() {
           
           isLoading = true
           
           db.collection("foodItems")
               .whereField("isAvailable", isEqualTo: true)
               .order(by: "createdAt", descending: true)
               .limit(to: 10)
               .getDocuments { [weak self] snapshot, error in
                   DispatchQueue.main.async {
                       self?.isLoading = false
                       
                       if let error = error {
                           self?.errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
                           return
                       }
                       
                       guard let documents = snapshot?.documents else {
                           self?.recommendedItems = []
                           return
                       }
                       
                       let items = documents.compactMap { document -> FoodItem? in
                           try? document.data(as: FoodItem.self)
                       }
                       
                       self?.recommendedItems = items
                   }
               }
       }
       
       
       func fetchSavedItems(savedIds: [String]) {
           if savedIds.isEmpty {
               DispatchQueue.main.async {
                   self.savedItems = []
                   self.isLoading = false
               }
               return
           }
           
           isLoading = true
           savedItems = []
           
           
           let chunkedIds = stride(from: 0, to: savedIds.count, by: 10).map {
               Array(savedIds[$0..<min($0 + 10, savedIds.count)])
           }
           
           var loadedItems: [FoodItem] = []
           var completedChunks = 0
           var firstError: Error?
           
           for chunk in chunkedIds {
               db.collection("foodItems")
                   .whereField(FieldPath.documentID(), in: chunk)
                   .getDocuments { [weak self] snapshot, error in
                       completedChunks += 1
                       
                       if let error = error {
                           if firstError == nil {
                               firstError = error
                           }
                       } else if let documents = snapshot?.documents {
                           let items = documents.compactMap { document -> FoodItem? in
                               try? document.data(as: FoodItem.self)
                           }
                           loadedItems.append(contentsOf: items)
                       }
                       
                       
                       if completedChunks == chunkedIds.count {
                           DispatchQueue.main.async {
                               self?.isLoading = false
                               
                               if let error = firstError {
                                   self?.errorMessage = "Fehler beim Laden der gespeicherten Elemente: \(error.localizedDescription)"
                               } else {
                                   
                                   self?.savedItems = loadedItems.sorted(by: { $0.createdAt > $1.createdAt })
                               }
                           }
                       }
                   }
           }
       }
    func toggleSaveItem(item: FoodItem, user: FireUser?, completion: @escaping (Bool) -> Void) {
        guard let user = user else {
            completion(false)
            return
        }
        
        var savedItems = user.savedItems 
        
        let isSaved = savedItems.contains(item.id)
        
        if isSaved {
            savedItems.removeAll(where: { $0 == item.id })
        } else {
            savedItems.append(item.id)
        }
        
        db.collection("users").document(user.id).updateData([
            "savedItems": savedItems
        ]) { error in
            if let error = error {
                print("Fehler beim Aktualisieren der gespeicherten Elemente: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            completion(true)
        }
    }
       
//       func toggleSaveItem(item: FoodItem, user: FireUser?, completion: @escaping (Bool) -> Void) {
//           guard let user = user, var savedItems = user.savedItems else {
//               completion(false)
//               return
//           }
//           
//           
//           let isSaved = savedItems.contains(item.id)
//           
//           if isSaved {
//               
//               savedItems.removeAll(where: { $0 == item.id })
//           } else {
//               
//               savedItems.append(item.id)
//           }
//           
//           
//           db.collection("users").document(user.id).updateData([
//               "savedItems": savedItems
//           ]) { error in
//               if let error = error {
//                   print("Fehler beim Aktualisieren der gespeicherten Elemente: \(error.localizedDescription)")
//                   completion(false)
//                   return
//               }
//               
//               completion(!isSaved)
//           }
//       }
       
       
       func isItemSaved(itemId: String, user: FireUser?) -> Bool {
           guard let savedItems = user?.savedItems else {
               return false
           }
           
           return savedItems.contains(itemId)
       }
   }
