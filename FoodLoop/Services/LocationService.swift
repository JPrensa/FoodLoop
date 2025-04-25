//
//  LocationService.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation
import CoreLocation
import SwiftUI
import Combine

// LocationService für die zentrale Verwaltung von Standortfunktionen
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    // Published-Eigenschaften für SwiftUI-Updates
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationName: String = "Unbekannt"
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    // Location Manager
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    // Für distanzbasierte Updates
    private var lastSignificantLocation: CLLocation?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // Location Manager konfigurieren
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100 // Aktualisierung bei 100m Änderung
    }
    
    // Standortberechtigung anfordern
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Standortaktualisierungen starten
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            errorMessage = "Standortberechtigung erforderlich"
            return
        }
        
        isLoading = true
        locationManager.startUpdatingLocation()
    }
    
    // Standortaktualisierungen stoppen
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    // Standort einmalig abrufen
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            errorMessage = "Standortberechtigung erforderlich"
            return
        }
        
        isLoading = true
        locationManager.requestLocation()
    }
    
    // Standort in Adresse umwandeln
    func reverseGeocode(location: CLLocation, completion: @escaping (String?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Fehler bei der Geokodierung: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first {
                // Adresse formatieren
                let address = [
                    placemark.locality,
                    placemark.thoroughfare,
                    placemark.subLocality,
                    placemark.postalCode
                ].compactMap { $0 }.joined(separator: ", ")
                
                completion(address.isEmpty ? "Unbekannter Standort" : address)
            } else {
                completion(nil)
            }
        }
    }
    
    // CLLocationManagerDelegate Methoden
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        
        guard let location = locations.last else { return }
        
        // Filtern von ungenauen Standorten
        if location.horizontalAccuracy < 0 || location.horizontalAccuracy > 100 {
            return
        }
        
        // Prüfen, ob sich der Standort signifikant geändert hat
        if let lastLocation = lastSignificantLocation {
            let distance = location.distance(from: lastLocation)
            if distance < 50 { // Weniger als 50m Änderung ignorieren
                return
            }
        }
        
        // Standort speichern
        currentLocation = location
        lastSignificantLocation = location
        
        // Adresse ermitteln
        reverseGeocode(location: location) { [weak self] address in
            DispatchQueue.main.async {
                if let address = address {
                    self?.locationName = address
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        print("Standortfehler: \(error.localizedDescription)")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                errorMessage = "Standortzugriff verweigert"
            case .network:
                errorMessage = "Netzwerkfehler. Bitte prüfe deine Verbindung"
            default:
                errorMessage = "Standortfehler: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "Standortfehler: \(error.localizedDescription)"
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Bei Berechtigung Standort sofort abrufen
            requestLocation()
        case .denied, .restricted:
            errorMessage = "Standortzugriff verweigert. Bitte ändere die Einstellungen in den Systemeinstellungen."
        case .notDetermined:
            // Warten auf Benutzeraktion
            break
        @unknown default:
            break
        }
    }
    
    // Distanz zwischen zwei Standorten berechnen
    func calculateDistance(to targetLocation: CLLocation) -> CLLocationDistance? {
        guard let currentLocation = currentLocation else { return nil }
        return currentLocation.distance(from: targetLocation)
    }
    
    // Nutzerfreundliche Formatierung der Entfernung
    func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            let kilometers = distance / 1000
            return String(format: "%.1f km", kilometers)
        }
    }
    
    // Distanz zu einer Location-Struktur berechnen
    func distanceToLocation(_ location: Location) -> String {
        guard let currentLocation = currentLocation else { return "?" }
        
        let targetLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        let distance = currentLocation.distance(from: targetLocation)
        return formatDistance(distance)
    }
    
    // Location-Struktur aus CLLocation erstellen
    func createLocation(from clLocation: CLLocation, withAddress address: String? = nil) -> Location {
        Location(
            latitude: clLocation.coordinate.latitude,
            longitude: clLocation.coordinate.longitude,
            address: address ?? locationName
        )
    }
}

// Erweiterung der Location-Struktur für bessere MapKit-Integration
extension Location {
    // Umwandlung in CLLocationCoordinate2D
    var coordinateArea: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Umwandlung in CLLocation
    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Initialisierung aus CLLocation
    init(clLocation: CLLocation, address: String? = nil) {
        self.latitude = clLocation.coordinate.latitude
        self.longitude = clLocation.coordinate.longitude
        self.address = address
    }
    
    // Berechnung der Entfernung zu einem anderen Standort
    func distanceArea(to location: Location) -> Double {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return from.distance(from: to)
    }
    
    // Berechnung der Entfernung zum aktuellen Benutzerstandort
    func distanceToCurrentLocation() -> String {
        return LocationService.shared.distanceToLocation(self)
    }
}
