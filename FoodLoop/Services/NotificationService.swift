//
//  NotificationService.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//

import Foundation
import Firebase
import FirebaseFirestore

// Service for sending app notifications via Firestore
class NotificationService {
    static let shared = NotificationService()
    private let database = Firestore.firestore()

    // Sends a reservation notification to the item's owner
    func sendReservationNotification(to ownerId: String, reserverId: String, foodItem: FoodItem) {
        let data: [String: Any] = [
            "ownerId": ownerId,
            "reserverId": reserverId,
            "foodItemId": foodItem.id,
            "foodTitle": foodItem.title,
            "timestamp": Timestamp(date: Date())
        ]
        database.collection("notifications").addDocument(data: data)
    }
}
