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
    @Published var owner: FireUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let database = Firestore.firestore()

    func fetchFoodItem(id: String) {
        isLoading = true
        database.collection("foodItems").document(id).getDocument { [weak self] document, error in
            guard let self = self else { return }
            DispatchQueue.main.async { self.isLoading = false }
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Fehler beim Laden des Lebensmittels: \(error.localizedDescription)"
                }
                return
            }
            guard let document = document, document.exists else { return }
            do {
                let item = try document.data(as: FoodItem.self)
                DispatchQueue.main.async {
                    self.foodItem = item
                    self.fetchOwner(id: item.ownerId)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Fehler beim Dekodieren des Lebensmittels: \(error.localizedDescription)"
                }
            }
        }
    }

    func fetchOwner(id: String) {
        database.collection("users").document(id).getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Fehler beim Laden des Besitzers: \(error.localizedDescription)"
                }
                return
            }
            guard let document = document, document.exists else { return }
            do {
                let user = try document.data(as: FireUser.self)
                DispatchQueue.main.async {
                    self.owner = user
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Fehler beim Dekodieren des Besitzers: \(error.localizedDescription)"
                }
            }
        }
    }

    func submitRating(stars: Double, comment: String?) {
        // Bewertung abgeben
    }

    /// Reserviert das Lebensmittel und sendet eine Benachrichtigung an den Besitzer
    func reserveFood() {
        guard let foodItem = foodItem else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.errorMessage = "Sie müssen angemeldet sein, um zu reservieren."
            }
            return
        }
        // Als reserviert markieren
        database.collection("foodItems").document(foodItem.id).updateData(["isAvailable": false]) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Fehler beim Reservieren: \(error.localizedDescription)"
                }
                return
            }
            NotificationService.shared.sendReservationNotification(to: foodItem.ownerId, reserverId: currentUserId, foodItem: foodItem)
            DispatchQueue.main.async {
                // Lokal als reserviert markieren
                self.foodItem?.isAvailable = false
            }
        }
    }

    /// Hebt die Reservierung auf und markiert das Item wieder verfügbar
    func unreserveFood() {
        guard let foodItem = foodItem else { return }
        database.collection("foodItems").document(foodItem.id).updateData(["isAvailable": true]) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Fehler beim Aufheben der Reservierung: \(error.localizedDescription)"
                }
                return
            }
            DispatchQueue.main.async {
                self.foodItem?.isAvailable = true
            }
        }
    }
}
