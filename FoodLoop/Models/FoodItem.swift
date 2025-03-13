//
//  FoodItem.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation

struct FoodItem: Identifiable, Codable {
    let id: String
    let ownerId: String
    var title: String
    var description: String
    var category: FoodCategory
    var imageURL: String?
    var location: Location
    var createdAt: Date
    var expiryDate: Date?
    var availableTimes: [AvailableTimeSlot]
    var isAvailable: Bool = true
    var ratings: [Rating]?
    
    var averageRating: Double? {
        guard let ratings = ratings, !ratings.isEmpty else { return nil }
        return ratings.map { $0.stars }.reduce(0, +) / Double(ratings.count)
    }
}
