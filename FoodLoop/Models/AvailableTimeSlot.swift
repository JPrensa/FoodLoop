//
//  AvailableTimeSlot.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation

struct AvailableTimeSlot: Codable, Identifiable, Hashable {
    var id = UUID().uuidString
    var day: Int // 0-6 für Wochentage
    var startTime: Date
    var endTime: Date
    
    // Wochentag als String
    var dayName: String {
        let weekdays = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
        return weekdays[day]
    }
    
    // Formatierte Zeitspanne
    var timeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let start = formatter.string(from: startTime)
        let end = formatter.string(from: endTime)
        
        return "\(start) - \(end)"
    }
    
    // Gleichheitsoperator
    static func == (lhs: AvailableTimeSlot, rhs: AvailableTimeSlot) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hashfunktion
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
