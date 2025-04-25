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
import CoreLocation
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
    @Published var searchText: String = ""
    @Published var searchLocation: CLLocationCoordinate2D?
    
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
        createDefaultCategories()
        setupBindings()
    }
    
    private func createDefaultCategories() {
        let defaultCategories = [
            FoodCategory(id: UUID().uuidString, name: "Obst & Gemüse", icon: "leaf.fill"),
            FoodCategory(id: UUID().uuidString, name: "Backwaren", icon: "birthday.cake"),
            FoodCategory(id: UUID().uuidString, name: "Milchprodukte", icon: "drop.fill"),
            FoodCategory(id: UUID().uuidString, name: "Fertiggerichte", icon: "fork.knife"),
            FoodCategory(id: UUID().uuidString, name: "Konserven", icon: "shippingbox.fill")
        ]
        self.availableCategories = defaultCategories
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
            
            let loadedCats = categoriesSnapshot.documents.compactMap { doc in
                try? doc.data(as: FoodCategory.self)
            }
            if !loadedCats.isEmpty {
                self.availableCategories = loadedCats
            }
            
            // Lebensmittel laden
            let query = db.collection("foodItems")
                .whereField("isAvailable", isEqualTo: true)
                //.order(by: "createdAt", descending: true)
            
            let snapshot = try await query.getDocuments()
            
            foodItems = snapshot.documents.compactMap { doc in
                try? doc.data(as: FoodItem.self)
            }
            .sorted(by: { $0.createdAt > $1.createdAt })
            
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
        // Bestimme Zentrum für Filterung
        let centerCoordinate: CLLocationCoordinate2D
        if let searchLoc = searchLocation {
            centerCoordinate = searchLoc
        } else if let userLoc = locationService.currentLocation {
            centerCoordinate = userLoc.coordinate
        } else {
            centerCoordinate = region.center
        }
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        
        filteredItems = foodItems.filter { item in
            // Ausschluss eigener Items
            if let uid = Auth.auth().currentUser?.uid, item.ownerId == uid {
                return false
            }
            // Entfernung prüfen
            let itemLoc = CLLocation(latitude: item.location.latitude, longitude: item.location.longitude)
            let distance = centerLocation.distance(from: itemLoc) / 1000
            let radiusMatch = distance <= radiusInKm
            // Kategorie prüfen
            let categoryMatch = selectedCategories.isEmpty || selectedCategories.contains(item.category.id)
            return radiusMatch && categoryMatch
        }
        // Nach Entfernung sortieren
        filteredItems.sort { item1, item2 in
            let loc1 = CLLocation(latitude: item1.location.latitude, longitude: item1.location.longitude)
            let loc2 = CLLocation(latitude: item2.location.latitude, longitude: item2.location.longitude)
            return centerLocation.distance(from: loc1) < centerLocation.distance(from: loc2)
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
    
    // Geocode für Ortssuche
    func geocodeAddress() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchText) { [weak self] placemarks, error in
            guard let self = self,
                  let loc = placemarks?.first?.location else { return }
            DispatchQueue.main.async {
                self.searchLocation = loc.coordinate
                // Region anpassen basierend auf Radius
                let latDelta = self.radiusInKm / 110.0
                let lonDelta = self.radiusInKm / (110.0 * cos(loc.coordinate.latitude * .pi / 180))
                self.region = MKCoordinateRegion(
                    center: loc.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: latDelta * 2, longitudeDelta: lonDelta * 2)
                )
                self.applyFilters()
            }
        }
    }
}

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}
