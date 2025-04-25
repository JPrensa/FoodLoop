import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth
import Combine

class HomeViewModel: ObservableObject {
    // Daten
    @Published var nearbyItems: [FoodItem] = []
    @Published var recommendedItems: [FoodItem] = []
    @Published var searchResults: [FoodItem] = []
    @Published var userItems: [FoodItem] = []
    @Published var availableCategories: [FoodCategory] = []
    
    // Status
    @Published var isLoading: Bool = false
    @Published var isSearching: Bool = false
    @Published var isSearchMode: Bool = false
    @Published var isFirstLoad: Bool = true
    @Published var alertMessage: AlertMessage?
    @Published var showFilters: Bool = false
    
    // Filter
    @Published var selectedCategories = Set<String>()
    @Published var maxDistance: Double = 10.0
    @Published var includeExpired: Bool = false
    
    // Sortierung
    enum SortOrder {
        case distance, newest, expiry
    }
    
    @Published var sortBy: SortOrder = .distance {
        didSet {
            if oldValue != sortBy {
                sortItems()
            }
        }
    }
    
    // Services
    let locationService = LocationService.shared
    private let db = Firestore.firestore()
    
    // Abonnements
    private var cancellables = Set<AnyCancellable>()
    
    // Alle Lebensmittel (für Filter und Suche)
    private var allItems: [FoodItem] = []
    
    init() {
        setupLocationBinding()
    }
    
    private func setupLocationBinding() {
        // Auf Standortänderungen reagieren
        locationService.$currentLocation
            .sink { [weak self] location in
                if location != nil {
                    // Bei erster Standortaktualisierung Daten laden
                    if self?.isFirstLoad == true {
                        self?.isFirstLoad = false
                        Task {
                            await self?.loadData()
                        }
                    } else if !self!.isLoading {
                        // Bei weiteren Aktualisierungen Entfernungen neu berechnen
                        self?.sortItems()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // Standortberechtigung anfordern
    func requestLocationPermission() {
        locationService.requestLocationPermission()
        
        // Wenn der Benutzer die Berechtigung bereits erteilt hat, direkt fortfahren
        if locationService.authorizationStatus == .authorizedWhenInUse ||
           locationService.authorizationStatus == .authorizedAlways {
            isFirstLoad = false
            locationService.startLocationUpdates()
            
            Task {
                await loadData()
            }
        }
    }
    
    // Standort aktualisieren
    func refreshLocation() {
        locationService.requestLocation()
    }
    
    // Daten laden
    @MainActor
    func loadData() async {
        if locationService.authorizationStatus == .notDetermined {
            // Beim ersten Laden Standortberechtigung anfordern
            isFirstLoad = true
            return
        }
        
        isLoading = true
        
        do {
            // Kategorien laden
            let categoriesSnapshot = try await db.collection("categories").getDocuments()
            // Einmalige Kategorien nach Name extrahieren und alphabetisch sortieren
            let rawCategories = categoriesSnapshot.documents.compactMap { doc in
                try? doc.data(as: FoodCategory.self)
            }
            var seenNames = Set<String>()
            availableCategories = rawCategories
                .filter { seenNames.insert($0.name).inserted }
                .sorted { $0.name < $1.name }
            
            // Lebensmittel laden
            let foodItemsSnapshot = try await db.collection("foodItems")
                .whereField("isAvailable", isEqualTo: true)
               // .order(by: "createdAt", descending: true)
                .getDocuments()
            
            
            allItems = foodItemsSnapshot.documents.compactMap { doc in
                try? doc.data(as: FoodItem.self)
            }
            .sorted(by: { $0.createdAt > $1.createdAt })
            
            // Eigene Uploads des aktuellen Benutzers laden
            if let uid = Auth.auth().currentUser?.uid {
                self.userItems = allItems.filter { $0.ownerId == uid }
            }

            // Filter und Sortierung anwenden
            filterAndSortItems()
            
            isLoading = false
        } catch {
            isLoading = false
            alertMessage = AlertMessage(message: "Fehler beim Laden der Daten: \(error.localizedDescription)")
        }
    }
    
    // Daten aktualisieren
    @MainActor
    func refreshData() async {
        await loadData()
    }
    
    // Filter anwenden und Elemente sortieren
    func filterAndSortItems() {
        var filtered = allItems
        
        // Nach Ablaufdatum filtern
        if !includeExpired {
            filtered = filtered.filter { item in
                if let expiryDate = item.expiryDate {
                    return expiryDate >= Date()
                }
                return true
            }
        }
        
        // Nach Kategorien filtern
        if !selectedCategories.isEmpty {
            filtered = filtered.filter { item in
                selectedCategories.contains(item.category.name)
            }
        }
        
        // Nach Entfernung filtern
        if let userLocation = locationService.currentLocation {
            filtered = filtered.filter { item in
                let itemLocation = CLLocation(
                    latitude: item.location.latitude,
                    longitude: item.location.longitude
                )
                
                let distance = userLocation.distance(from: itemLocation) / 1000 // km
                return distance <= maxDistance
            }
        }
        
        // Gefilterte Elemente zuweisen und sortieren
        nearbyItems = filtered
        sortItems()
    }
    
    // Sortierung anwenden
    func sortItems() {
        switch sortBy {
        case .distance:
            // Nach Entfernung sortieren (wenn Standort verfügbar)
            if let userLocation = locationService.currentLocation {
                nearbyItems.sort { item1, item2 in
                    let location1 = CLLocation(latitude: item1.location.latitude, longitude: item1.location.longitude)
                    let location2 = CLLocation(latitude: item2.location.latitude, longitude: item2.location.longitude)
                    
                    return userLocation.distance(from: location1) < userLocation.distance(from: location2)
                }
            }
        case .newest:
            // Nach Erstelldatum sortieren (neueste zuerst)
            nearbyItems.sort { $0.createdAt > $1.createdAt }
        case .expiry:
            // Nach Ablaufdatum sortieren (bald ablaufende zuerst, dann ohne Ablaufdatum)
            nearbyItems.sort { item1, item2 in
                if let date1 = item1.expiryDate, let date2 = item2.expiryDate {
                    return date1 < date2
                } else if item1.expiryDate != nil {
                    return true
                } else if item2.expiryDate != nil {
                    return false
                } else {
                    return item1.createdAt > item2.createdAt
                }
            }
        }
    }
    
    // Empfehlungen basierend auf Präferenzen erstellen
    func createRecommendations() {
        // Hier könnte eine komplexere Logik für personalisierte Empfehlungen implementiert werden
        // Für den Prototyp: eine zufällige Auswahl aus allen Elementen
        
        var recommendations = allItems
        
        // Nicht die gleichen Elemente wie in nearbyItems anzeigen
        if !nearbyItems.isEmpty {
            let nearbyIds = Set(nearbyItems.map { $0.id })
            recommendations = recommendations.filter { !nearbyIds.contains($0.id) }
        }
        
        // Nach Erstelldatum sortieren und auf 10 Elemente begrenzen
        recommendedItems = Array(recommendations.sorted { $0.createdAt > $1.createdAt }.prefix(10))
    }
    
    // Suche durchführen
    func searchFoodItems(query: String) {
        guard !query.isEmpty else {
            clearSearch()
            return
        }
        
        isSearching = true
        
        // Filter und Sortierung anwenden vor Suche
        filterAndSortItems()
        let lowercaseQuery = query.lowercased()
        // Suche nur in den nahen Items
        searchResults = nearbyItems.filter { item in
            item.title.lowercased().contains(lowercaseQuery) ||
            item.description.lowercased().contains(lowercaseQuery) ||
            item.category.name.lowercased().contains(lowercaseQuery)
        }
        
        isSearching = false
    }
    
    // Suche zurücksetzen
    func clearSearch() {
        searchResults = []
        isSearchMode = false
        isSearching = false
    }
    
    // Filter zurücksetzen
    func resetFilters() {
        selectedCategories.removeAll()
        maxDistance = 10.0
        includeExpired = false
    }
    
    // Filter anwenden
    func applyFilters() {
        filterAndSortItems()
    }
}
