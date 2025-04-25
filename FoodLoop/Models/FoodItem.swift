//
//  FoodItem.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation
import CoreLocation
import FirebaseFirestore


struct FoodItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    var ownerId: String
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
    
    // Berechnung der durchschnittlichen Bewertung
    var averageRating: Double? {
        guard let ratings = ratings, !ratings.isEmpty else { return nil }
        return ratings.map { $0.stars }.reduce(0, +) / Double(ratings.count)
    }
    
    // Prüfen, ob das Lebensmittel abgelaufen ist
    var isExpired: Bool {
        guard let expiryDate = expiryDate else { return false }
        return expiryDate < Date()
    }
    
    // Entfernung zum aktuellen Standort
    func distanceFromCurrentLocation() -> String {
        return location.distanceFromCurrentLocation()
    }
    
    // Numerischer Abstand vom aktuellen Standort (für Sortierung)
    func distanceValue() -> Double? {
        guard let currentLocation = LocationService.shared.currentLocation else {
            return nil
        }
        
        return location.clLocation.distance(from: currentLocation)
    }
    
    // Status der Verfügbarkeit basierend auf Abholzeiten
    func availabilityStatus() -> String {
        if availableTimes.isEmpty {
            return "Jederzeit verfügbar"
        }
        
        let today = Calendar.current.component(.weekday, from: Date()) - 2 // 0 = Montag
        
        // Prüfen, ob heute eine Abholzeit verfügbar ist
        if availableTimes.contains(where: { $0.day == today }) {
            return "Heute verfügbar"
        }
        
        // Finden des nächsten verfügbaren Tages
        let weekdays = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
        let nextDays = availableTimes.map { $0.day }
            .filter { day in
                // Tage nach heute finden
                let adjustedDay = day < today ? day + 7 : day
                return adjustedDay > today
            }
            .sorted()
        
        if let nextDay = nextDays.first {
            let adjustedNextDay = nextDay >= 7 ? nextDay - 7 : nextDay
            return "Verfügbar am \(weekdays[adjustedNextDay])"
        }
        
        return "Verfügbar"
    }
    
    // Formatierte Abholzeiten
    func formattedPickupTimes() -> String {
        if availableTimes.isEmpty {
            return "Keine Abholzeiten angegeben"
        }
        
        let weekdays = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let times = availableTimes.map { timeSlot in
            let day = weekdays[timeSlot.day]
            let start = formatter.string(from: timeSlot.startTime)
            let end = formatter.string(from: timeSlot.endTime)
            return "\(day), \(start) - \(end)"
        }
        
        return times.joined(separator: "\n")
    }
}
