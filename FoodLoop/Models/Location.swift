//
//  Location.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    var address: String?
    
    func distance(to location: Location) -> Double {
        // Berechnung der Entfernung zwischen zwei Standorten
        // Implementierung mit CLLocation
        return 0.0
    }
}
