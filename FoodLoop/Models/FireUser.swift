//
//  User.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation

struct FireUser: Identifiable, Codable {
    let id: String
    var username: String
    var email: String?
    var location: Location?
    var profileImageURL: String?
    var phoneNumber: String?
    var preferences: [FoodCategory]?
    var savedItems: [String] // IDs der gespeicherten Lebensmittel
    var level: Int
    var foodsSaved: Int
    let createdAt: Date
    
    // Berechnete Eigenschaft für Nutzerebene
    var levelTitle: String {
        switch level {
        case 0...5: return "Einsteiger"
        case 6...15: return "Fortgeschritten"
        case 16...30: return "Experte"
        default: return "Lebensmittelretter"
        }
    }
}
