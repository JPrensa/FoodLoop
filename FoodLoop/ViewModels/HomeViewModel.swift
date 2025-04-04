
import SwiftUI
import MapKit
import FirebaseFirestore
import Combine

class HomeViewModel: ObservableObject {
    // Daten
    @Published var nearbyItems: [FoodItem] = []
    @Published var recommendedItems: [FoodItem] = []
    @Published var searchResults: [FoodItem] = []
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
            
            availableCategories = categoriesSnapshot.documents.compactMap { doc in
                try? doc.data(as: FoodCategory.self)
            }
            
            // Lebensmittel laden
            let foodItemsSnapshot = try await db.collection("foodItems")
                .whereField("isAvailable", isEqualTo: true)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            allItems = foodItemsSnapshot.documents.compactMap { doc in
                try? doc.data(as: FoodItem.self)
            }
            
            // Filter und Sortierung anwenden
            filterAndSortItems()
            
            // Empfehlungen erstellen (vorrangig basierend auf Kategorien)
            createRecommendations()
            
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
                selectedCategories.contains(item.category.id)
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
        
        // In Firestore können wir keine Volltextsuche durchführen
        // Daher filtern wir die bereits geladenen Elemente clientseitig
        let lowercaseQuery = query.lowercased()
        
        searchResults = allItems.filter { item in
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


//class HomeViewModel: ObservableObject {
//    @Published var nearbyItems: [FoodItem] = []
//    @Published var recommendedItems: [FoodItem] = []
//    @Published var searchResults: [FoodItem] = []
//    @Published var isLoading = false
//    @Published var isSearching = false
//    @Published var isSearchMode = false
//    @Published var errorMessage: String?
//    
//    private let db = Firestore.firestore()
//    private let locationManager = CLLocationManager()
//    private var userLocation: CLLocation?
//    
//    // Standort anfordern
//    func requestLocation() {
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        
//        if let location = locationManager.location {
//            userLocation = location
//            
//            
//            Task {
//                await refreshData()
//            }
//        }
//    }
//    
//    
//    @MainActor
//    func refreshData() async {
//        isLoading = true
//        
//        
//        await withTaskGroup(of: Void.self) { group in
//            group.addTask {
//                await self.fetchNearbyItems()
//            }
//            
//            group.addTask {
//                await self.fetchRecommendedItems()
//            }
//        }
//        
//        isLoading = false
//    }
//    
//    // Lebensmittel in der Nähe laden
//    @MainActor
//    private func fetchNearbyItems() async {
//        do {
//            var query = db.collection("foodItems")
//                .whereField("isAvailable", isEqualTo: true)
//                .order(by: "createdAt", descending: true)
//                .limit(to: 20)
//            
//            let snapshot = try await query.getDocuments()
//            
//            // Lebensmittel dekodieren
//            let items = snapshot.documents.compactMap { document -> FoodItem? in
//                try? document.data(as: FoodItem.self)
//            }
//            
//            // Wenn ein Standort vorhanden ist, nach Entfernung sortieren
//            if let userLocation = userLocation {
//                nearbyItems = items.sorted { item1, item2 in
//                    let location1 = CLLocation(latitude: item1.location.latitude, longitude: item1.location.longitude)
//                    let location2 = CLLocation(latitude: item2.location.latitude, longitude: item2.location.longitude)
//                    
//                    return location1.distance(from: userLocation) < location2.distance(from: userLocation)
//                }
//            } else {
//                // Sonst nach Erstellungsdatum sortieren
//                nearbyItems = items
//            }
//        } catch {
//            print("Fehler beim Laden der Lebensmittel: \(error.localizedDescription)")
//            errorMessage = "Fehler beim Laden der Lebensmittel"
//        }
//    }
//    
//    // Empfohlene Lebensmittel laden
//    @MainActor
//    private func fetchRecommendedItems() async {
//        do {
//            
//            let query = db.collection("foodItems")
//                .whereField("isAvailable", isEqualTo: true)
//                .order(by: "createdAt", descending: true)
//                .limit(to: 10)
//            
//            let snapshot = try await query.getDocuments()
//            
//            recommendedItems = snapshot.documents.compactMap { document -> FoodItem? in
//                try? document.data(as: FoodItem.self)
//            }
//        } catch {
//            print("Fehler beim Laden der empfohlenen Lebensmittel: \(error.localizedDescription)")
//           
//        }
//    }
//    
//    // Lebensmittel suchen
//    func searchFoodItems(query: String) {
//        guard !query.isEmpty else {
//            clearSearch()
//            return
//        }
//        
//        isSearching = true
//        
//        // In Firestore können wir keine Volltextsuche durchführen
//        // Daher holen wir Elemente und filtern sie clientseitig
//        db.collection("foodItems")
//            .whereField("isAvailable", isEqualTo: true)
//            .limit(to: 50) // Höheres Limit für die Suche
//            .getDocuments { [weak self] snapshot, error in
//                guard let self = self else { return }
//                
//                DispatchQueue.main.async {
//                    self.isSearching = false
//                    
//                    if let error = error {
//                        self.errorMessage = "Suchfehler: \(error.localizedDescription)"
//                        return
//                    }
//                    
//                    guard let documents = snapshot?.documents else {
//                        self.searchResults = []
//                        return
//                    }
//                    
//                    // Dekodieren und Filtern
//                    let allItems = documents.compactMap { document -> FoodItem? in
//                        try? document.data(as: FoodItem.self)
//                    }
//                    
//                    // Filtern nach Übereinstimmungen im Titel oder in der Beschreibung
//                    let lowercaseQuery = query.lowercased()
//                    self.searchResults = allItems.filter { item in
//                        item.title.lowercased().contains(lowercaseQuery) ||
//                        item.description.lowercased().contains(lowercaseQuery) ||
//                        item.category.name.lowercased().contains(lowercaseQuery)
//                    }
//                }
//            }
//    }
//    
//    // Suche zurücksetzen
//    func clearSearch() {
//        searchResults = []
//        isSearchMode = false
//        isSearching = false
//    }
//}
