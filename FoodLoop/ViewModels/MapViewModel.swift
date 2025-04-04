//
//  MapViewModel.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import MapKit
import Combine

class MapViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var filteredItems: [FoodItem] = []
    @Published var selectedItem: FoodItem?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515), // Zentrum von Deutschland
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Filter-Optionen
    @Published var selectedCategories = Set<String>()
    @Published var radiusInKm: Double = 5.0
    @Published var availableCategories: [FoodCategory] = []
    @Published var showFilters: Bool = false
    
    // UI-Steuerung
    @Published var isLoading: Bool = false
    @Published var alertMessage: AlertMessage?
    @Published var showLocationPrompt: Bool = false
    @Published var navigateToDetailId: String?
    
    private let locationService = LocationService.shared
    private let db = Firestore.firestore()
    
    // Abonnement für Standortänderungen
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Auf Standortänderungen reagieren
        locationService.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                DispatchQueue.main.async {
                    self?.updateRegion(for: location.coordinate)
                }
            }
            .store(in: &cancellables)
        
        // Auf Filteränderungen reagieren
        Publishers.CombineLatest($selectedCategories, $radiusInKm)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (categories, radius) in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    // Daten laden
    @MainActor
    func loadItems() async {
        isLoading = true
        
        // Prüfen, ob Standort verfügbar ist
        if locationService.authorizationStatus == .notDetermined {
            showLocationPrompt = true
            isLoading = false
            return
        } else if locationService.authorizationStatus == .denied ||
                  locationService.authorizationStatus == .restricted {
            alertMessage = AlertMessage(message: "Standortzugriff verweigert. Bitte ändere die Einstellungen in den Systemeinstellungen.")
            isLoading = false
            return
        }
        
        // Wenn kein aktueller Standort vorhanden ist, anfordern
        if locationService.currentLocation == nil {
            locationService.requestLocation()
        }
        
        do {
            // Kategorien laden
            let categoriesQuery = db.collection("categories")
            let categoriesSnapshot = try await categoriesQuery.getDocuments()
            
            availableCategories = categoriesSnapshot.documents.compactMap { doc in
                try? doc.data(as: FoodCategory.self)
            }
            
            // Lebensmittel laden
            let query = db.collection("foodItems")
                .whereField("isAvailable", isEqualTo: true)
                .order(by: "createdAt", descending: true)
            
            let snapshot = try await query.getDocuments()
            
            foodItems = snapshot.documents.compactMap { doc in
                try? doc.data(as: FoodItem.self)
            }
            
            // Filter anwenden
            applyFilters()
            isLoading = false
        } catch {
            alertMessage = AlertMessage(message: "Fehler beim Laden der Daten: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // Filter anwenden
    func applyFilters() {
        // Wenn ein aktueller Standort vorhanden ist, nach Entfernung filtern
        if let userLocation = locationService.currentLocation {
            filteredItems = foodItems.filter { item in
                // Entfernung prüfen
                let itemLocation = CLLocation(latitude: item.location.latitude, longitude: item.location.longitude)
                let distance = userLocation.distance(from: itemLocation) / 1000 // km
                
                // Kategorie prüfen (wenn keine Kategorien ausgewählt sind, alle anzeigen)
                let categoryMatch = selectedCategories.isEmpty || selectedCategories.contains(item.category.id)
                
                return distance <= radiusInKm && categoryMatch
            }
            
            // Nach Entfernung sortieren
            filteredItems.sort { item1, item2 in
                let location1 = CLLocation(latitude: item1.location.latitude, longitude: item1.location.longitude)
                let location2 = CLLocation(latitude: item2.location.latitude, longitude: item2.location.longitude)
                
                return userLocation.distance(from: location1) < userLocation.distance(from: location2)
            }
        } else {
            // Ohne Standort nur nach Kategorie filtern
            filteredItems = foodItems.filter { item in
                selectedCategories.isEmpty || selectedCategories.contains(item.category.id)
            }
        }
    }
    
    // Region aktualisieren
    func updateRegion(for coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    // Karte neu zentrieren
    func recenterMap() {
        if let location = locationService.currentLocation {
            updateRegion(for: location.coordinate)
        } else {
            locationService.requestLocation()
        }
    }
    
    // Element auswählen
    func selectItem(_ item: FoodItem) {
        selectedItem = item
        
        // Auf das ausgewählte Element zentrieren
        updateRegion(for: item.location.coordinate)
    }
    
    // Standortberechtigung anfordern
    func requestLocationPermission() {
        locationService.requestLocationPermission()
        showLocationPrompt = false
    }
    
    // Filter zurücksetzen
    func resetFilters() {
        selectedCategories.removeAll()
        radiusInKm = 5.0
    }
}
struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

//class MapViewModel: ObservableObject {
//    @Published var foodItems: [FoodItem] = []
//    @Published var selectedItem: FoodItem?
//    @Published var userLocation: Location?
//    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
//    
//    func fetchItemsForMap() {
//        // Laden aller Lebensmittel für die Karte
//    }
//    
//    func updateRegion() {
//        // Aktualisieren der Kartenregion
//    }
//    
//    func selectItem(_ item: FoodItem) {
//        // Auswählen eines Items auf der Karte
//    }
//}
