//
//  Location.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//


//struct Location: Codable {
//    let latitude: Double
//    let longitude: Double
//    var address: String?
//    
//    func distance(to location: Location) -> Double {
//        // Berechnung der Entfernung zwischen zwei Standorten
//        // Implementierung mit CLLocation
//        return 0.0
//    }
//}
import Foundation
import CoreLocation
import FirebaseFirestore

// Aktualisiertes Location-Modell für bessere Standort-Integration
struct Location: Codable, Equatable, Hashable {
    var latitude: Double
    var longitude: Double
    var address: String?
    
    // Initialisierung mit Koordinaten
    init(latitude: Double, longitude: Double, address: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
    // Initialisierung mit CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D, address: String? = nil) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.address = address
    }
    
    // Umwandlung in CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Umwandlung in CLLocation
    var clLocationArea: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Berechnung der Entfernung zu einem anderen Standort
    func distance(to location: Location) -> Double {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return from.distance(from: to)
    }
    
    // Formatierte Entfernung zum aktuellen Standort
    func distanceFromCurrentLocation() -> String {
        guard let currentLocation = LocationService.shared.currentLocation else {
            return "Entfernung unbekannt"
        }
        
        let distance = self.clLocation.distance(from: currentLocation)
        
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            let kilometers = distance / 1000
            return String(format: "%.1f km", kilometers)
        }
    }
    
    // Gleichheitsoperator
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    // Hashfunktion
    func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
