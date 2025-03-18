// ViewModel für die HomeView
class HomeViewModel: ObservableObject {
    @Published var nearbyItems: [FoodItem] = []
    @Published var recommendedItems: [FoodItem] = []
    @Published var searchResults: [FoodItem] = []
    @Published var isLoading = false
    @Published var isSearching = false
    @Published var isSearchMode = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    
    // Standort anfordern
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let location = locationManager.location {
            userLocation = location
            
            // Daten mit dem neuen Standort neu laden
            Task {
                await refreshData()
            }
        }
    }
    
    // Daten neu laden (für Pull-to-Refresh und initiale Ladung)
    @MainActor
    func refreshData() async {
        isLoading = true
        
        // Gruppe für Concurrent Fetching
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.fetchNearbyItems()
            }
            
            group.addTask {
                await self.fetchRecommendedItems()
            }
        }
        
        isLoading = false
    }
    
    // Lebensmittel in der Nähe laden
    @MainActor
    private func fetchNearbyItems() async {
        do {
            var query = db.collection("foodItems")
                .whereField("isAvailable", isEqualTo: true)
                .order(by: "createdAt", descending: true)
                .limit(to: 20)
            
            let snapshot = try await query.getDocuments()
            
            // Lebensmittel dekodieren
            let items = snapshot.documents.compactMap { document -> FoodItem? in
                try? document.data(as: FoodItem.self)
            }
            
            // Wenn ein Standort vorhanden ist, nach Entfernung sortieren
            if let userLocation = userLocation {
                nearbyItems = items.sorted { item1, item2 in
                    let location1 = CLLocation(latitude: item1.location.latitude, longitude: item1.location.longitude)
                    let location2 = CLLocation(latitude: item2.location.latitude, longitude: item2.location.longitude)
                    
                    return location1.distance(from: userLocation) < location2.distance(from: userLocation)
                }
            } else {
                // Sonst nach Erstellungsdatum sortieren
                nearbyItems = items
            }
        } catch {
            print("Fehler beim Laden der Lebensmittel: \(error.localizedDescription)")
            errorMessage = "Fehler beim Laden der Lebensmittel"
        }
    }
    
    // Empfohlene Lebensmittel laden
    @MainActor
    private func fetchRecommendedItems() async {
        do {
            // Für die Empfehlungen könnten wir nach anderen Kriterien filtern
            // Hier holen wir einfach die neuesten Elemente
            let query = db.collection("foodItems")
                .whereField("isAvailable", isEqualTo: true)
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
            
            let snapshot = try await query.getDocuments()
            
            recommendedItems = snapshot.documents.compactMap { document -> FoodItem? in
                try? document.data(as: FoodItem.self)
            }
        } catch {
            print("Fehler beim Laden der empfohlenen Lebensmittel: \(error.localizedDescription)")
            // Fehler hier nicht anzeigen, da es ein sekundärer Bereich ist
        }
    }
    
    // Lebensmittel suchen
    func searchFoodItems(query: String) {
        guard !query.isEmpty else {
            clearSearch()
            return
        }
        
        isSearching = true
        
        // In Firestore können wir keine Volltextsuche durchführen
        // Daher holen wir Elemente und filtern sie clientseitig
        db.collection("foodItems")
            .whereField("isAvailable", isEqualTo: true)
            .limit(to: 50) // Höheres Limit für die Suche
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isSearching = false
                    
                    if let error = error {
                        self.errorMessage = "Suchfehler: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self.searchResults = []
                        return
                    }
                    
                    // Dekodieren und Filtern
                    let allItems = documents.compactMap { document -> FoodItem? in
                        try? document.data(as: FoodItem.self)
                    }
                    
                    // Filtern nach Übereinstimmungen im Titel oder in der Beschreibung
                    let lowercaseQuery = query.lowercased()
                    self.searchResults = allItems.filter { item in
                        item.title.lowercased().contains(lowercaseQuery) ||
                        item.description.lowercased().contains(lowercaseQuery) ||
                        item.category.name.lowercased().contains(lowercaseQuery)
                    }
                }
            }
    }
    
    // Suche zurücksetzen
    func clearSearch() {
        searchResults = []
        isSearchMode = false
        isSearching = false
    }
}